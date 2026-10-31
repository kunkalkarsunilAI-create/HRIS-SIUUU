// Sahyadri HRIS assistant: answers HR questions with Google Gemini.
// The Gemini API key stays here on the server (Supabase secret GEMINI_API_KEY).
// Every data lookup runs with the signed-in user's own token, so Row Level Security
// limits the assistant to exactly what that person may see in the app.
import { createClient } from "npm:@supabase/supabase-js@2.45.4";

// "gemini-flash-latest" always points at Google's current Flash model (free tier available).
// Override with a GEMINI_MODEL secret if needed.
const MODELS = [Deno.env.get("GEMINI_MODEL") || "gemini-flash-latest", "gemini-2.5-flash"];
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });

const POLICY = `Company: Sahyadri Tech Pvt Ltd, Pune (fictional demo company).
Leave policy (calendar year):
- CL casual leave 8 days/year, max 3 days at a stretch, no carry-forward.
- SL sick leave 8 days/year, medical certificate if more than 2 days.
- EL earned leave 18 days/year, accrues 1.5 days/month, carry forward up to 30. Interns get no EL.
- ML maternity leave 26 weeks (182 calendar days). PL paternity leave 5 days within 3 months of birth.
- LOP loss of pay: unpaid, reduces payable days.
- CL/SL/EL count working days only (weekends and company holidays skipped).
- Approval: reporting manager approves; requests over 5 working days and all maternity leave then go to HR.
- New joiners: 6-month probation; notice period 15 days in probation, 60 days after confirmation.
Company holidays 2026 (Pune): 26 Jan Republic Day, 4 Mar Holi, 20 Mar Ramzan Eid, 3 Apr Good Friday, 1 May Maharashtra Day,
15 Aug Independence Day, 14 Sep Ganesh Chaturthi, 2 Oct Gandhi Jayanti, 20 Oct Dussehra, 9 Nov Diwali (Lakshmi Puja),
10 Nov Diwali (Balipratipada), 24 Nov Guru Nanak Jayanti, 25 Dec Christmas.
Payroll structure: basic = 50% of CTC, HRA = 40% of basic, employer PF and gratuity (4.81% of basic) inside CTC, special allowance balances.
PF 12% of wages capped at Rs 15,000; ESI 0.75% employee / 3.25% employer when gross is Rs 21,000 or less;
Maharashtra PT: men nil to 7,500, 175 to 10,000, 200 above (300 in Feb); women nil to 25,000, 200 above. Karnataka PT 200 at 25,000+.
Statutory due dates: PF ECR and ESI by the 15th of the next month.`;

const TOOLS = [
  { name: "search_employees", description: "Find employees in the work directory by name, ID, designation or department. Returns work details only (no salary).",
    input_schema: { type: "object", properties: { query: { type: "string", description: "Text to match; empty for everyone" } }, required: [] } },
  { name: "get_leave_requests", description: "Leave requests the user is allowed to see (own; team for managers; all for HR). Optionally filter by employee ID or status.",
    input_schema: { type: "object", properties: { employee_id: { type: "string" }, status: { type: "string", enum: ["Pending manager","Pending HR","Approved","Rejected","Withdrawn"] } }, required: [] } },
  { name: "get_salary", description: "Annual CTC for an employee. Only returns data the user may see (HR: everyone; others: only themselves).",
    input_schema: { type: "object", properties: { employee_id: { type: "string" } }, required: ["employee_id"] } },
  { name: "get_documents", description: "Documents on file for an employee (HR: anyone; others: only themselves).",
    input_schema: { type: "object", properties: { employee_id: { type: "string" } }, required: ["employee_id"] } },
  { name: "get_attendance", description: "Check-in/check-out records for the current month (own; team for managers; all for HR).",
    input_schema: { type: "object", properties: { employee_id: { type: "string" } }, required: [] } },
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Use POST" }, 405);

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return json({ error: "The assistant isn't set up yet: HR needs to add the GEMINI_API_KEY secret in Supabase." }, 503);

  const auth = req.headers.get("Authorization") || "";
  const token = auth.replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "Sign in first." }, 401);

  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    accessToken: async () => token,
  });

  // Who is asking? This query runs under RLS with the caller's token, so it also verifies the token.
  let email = "";
  try {
    const b64 = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    const payload = JSON.parse(atob(b64 + "=".repeat((4 - (b64.length % 4)) % 4)));
    email = String(payload.email || "").toLowerCase();
  } catch { /* handled below */ }
  if (!email) return json({ error: "Your sign-in token has no email. HR should check the Clerk session token settings." }, 401);
  // The database verifies the token's signature on this query; a forged token fails here.
  const { data: me, error: meErr } = await db.from("app_logins").select("employee_id, role").eq("email", email).maybeSingle();
  if (meErr) return json({ error: "Your sign-in couldn't be verified. Sign out and in again." }, 401);
  if (!me) return json({ error: "Your account isn't linked to an employee record." }, 403);
  const { data: self } = await db.from("employees").select("id,name,designation,dept,manager_id,doj,location,type,status,lwd").eq("id", me.employee_id).maybeSingle();

  let body: { messages?: { role: string; content: string }[]; context?: unknown };
  try { body = await req.json(); } catch { return json({ error: "Bad request" }, 400); }
  const history = (body.messages || [])
    .filter((m) => (m.role === "user" || m.role === "assistant") && typeof m.content === "string")
    .slice(-12)
    .map((m) => ({ role: m.role, content: m.content.slice(0, 2000) }));
  if (!history.length || history[history.length - 1].role !== "user") return json({ error: "Ask a question." }, 400);

  const today = new Date().toISOString().slice(0, 10);
  const system = `You are the HR assistant inside Sahyadri HRIS. Today is ${today}.
You are talking to ${self?.name} (${me.employee_id}), ${self?.designation}, role in the app: ${me.role}.
Their own record: ${JSON.stringify(self)}.
Leave balances computed by the app for this user (trust these for "how many leaves do I have"): ${JSON.stringify(body.context ?? null).slice(0, 2000)}.

${POLICY}

Rules:
- Use the tools to look up data. They only return what this user is allowed to see; if a tool returns nothing, say you can't see that information, and never guess or invent records.
- Never reveal or ask for Aadhaar, PAN, bank details, gender, age, religion, caste or marital status.
- You can explain and look things up, but you cannot approve, reject or change anything. Tell the user where in the app to do it (Leave & attendance, Employees, Letters, Payroll inputs, Compliance).
- Decisions about people (performance, termination, hiring) are for a named human; give information, not verdicts.
- Answer briefly and plainly, in the user's language. Amounts in Indian rupees (Rs or ₹ with Indian digit grouping). Dates like 09 Nov 2026.`;

  async function runTool(name: string, input: Record<string, string>) {
    const pick = (r: { data: unknown; error: { message: string } | null }) => r.error ? { error: r.error.message } : r.data;
    switch (name) {
      case "search_employees": {
        let q = db.from("employees").select("id,name,designation,dept,manager_id,doj,location,type,status,lwd,email").order("id");
        const t = (input.query || "").trim();
        if (t) q = q.or(`name.ilike.%${t.replace(/[%,()]/g, "")}%,id.ilike.%${t.replace(/[%,()]/g, "")}%,designation.ilike.%${t.replace(/[%,()]/g, "")}%,dept.ilike.%${t.replace(/[%,()]/g, "")}%`);
        return pick(await q.limit(30));
      }
      case "get_leave_requests": {
        let q = db.from("leave_requests").select("id,employee_id,type,from_date,to_date,status,reason,applied_on").order("from_date", { ascending: false });
        if (input.employee_id) q = q.eq("employee_id", input.employee_id);
        if (input.status) q = q.eq("status", input.status);
        return pick(await q.limit(50));
      }
      case "get_salary":
        return pick(await db.from("employee_sensitive").select("employee_id,ctc").eq("employee_id", input.employee_id));
      case "get_documents":
        return pick(await db.from("documents").select("name,kind,doc_date,status").eq("employee_id", input.employee_id));
      case "get_attendance": {
        const monthStart = today.slice(0, 8) + "01";
        let q = db.from("attendance").select("employee_id,day,check_in,check_out").gte("day", monthStart).order("day");
        if (input.employee_id) q = q.eq("employee_id", input.employee_id);
        return pick(await q.limit(200));
      }
    }
    return { error: "Unknown tool" };
  }

  // Tool-use loop: Gemini asks for data, we fetch it under RLS, Gemini answers.
  const contents: unknown[] = history.map((m) => ({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.content }] }));
  const tools = [{ function_declarations: TOOLS.map((t) => ({ name: t.name, description: t.description, parameters: t.input_schema.required.length ? t.input_schema : { type: "object", properties: t.input_schema.properties } })) }];
  let model = MODELS[0];
  for (let step = 0; step < 6; step++) {
    let r = await callGemini(model);
    if (r.status === 404 && model !== MODELS[1]) { model = MODELS[1]; r = await callGemini(model); }
    const out = await r.json();
    if (!r.ok) {
      const msg = out?.error?.message || r.statusText;
      if (r.status === 429) return json({ error: "The free Gemini quota is used up for now. Wait a minute and try again." }, 429);
      return json({ error: `The AI service returned an error: ${msg}` }, 502);
    }
    const cand = out.candidates?.[0];
    const parts = cand?.content?.parts || [];
    const calls = parts.filter((p: { functionCall?: unknown }) => p.functionCall);
    if (calls.length) {
      contents.push(cand.content); // keep the model turn unchanged (includes thought signatures)
      const responses = [];
      for (const p of calls) {
        const fc = p.functionCall as { name: string; args?: Record<string, string>; id?: string };
        const result = await runTool(fc.name, fc.args || {});
        responses.push({ functionResponse: { name: fc.name, ...(fc.id ? { id: fc.id } : {}), response: { result: JSON.parse(JSON.stringify(result ?? null)) } } });
      }
      contents.push({ role: "user", parts: responses });
      continue;
    }
    const reply = parts.filter((p: { text?: string; thought?: boolean }) => p.text && !p.thought).map((p: { text: string }) => p.text).join("\n").trim();
    if (!reply && cand?.finishReason === "SAFETY") return json({ reply: "I can't help with that request." });
    return json({ reply: reply || "I couldn't find an answer to that." });
  }
  return json({ reply: "That needed too many lookups. Try asking a more specific question." });

  function callGemini(m: string) {
    return fetch(`https://generativelanguage.googleapis.com/v1beta/models/${m}:generateContent`, {
      method: "POST",
      headers: { "x-goog-api-key": apiKey!, "content-type": "application/json" },
      body: JSON.stringify({ system_instruction: { parts: [{ text: system }] }, contents, tools, generationConfig: { maxOutputTokens: 1500 } }),
    });
  }
});
