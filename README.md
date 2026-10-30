# Sahyadri HRIS

A demo HR Information System (core HRMS) built for the *New Age HR Applications using AI* course, following section 10 of the guide "Claude Skills for HR Tech".

It is a single `index.html` file with no build step. Data is stored in **Supabase** (Postgres) with Row Level Security on every table, and sign-in is handled by **Clerk**.

## Modules

- **Employee master** with search, filters, pagination and a validated add/edit form. PAN, UAN and salary are visible to HR Admin only; only the last 4 digits of Aadhaar are stored.
- **Org chart** built from reporting lines.
- **Leave and attendance**: balances, apply, manager approval (over 5 days and maternity leave go on to HR), monthly attendance grid, check-in/out, holiday calendar.
- **Payroll inputs**: monthly figures adjusted for loss-of-pay days, with PF, ESI and professional tax.
- **HR letters**: offer, confirmation, promotion, relieving and experience letters on letterhead.
- **Compliance**: PF ECR in EPFO upload format, ESI, professional tax (Maharashtra and Karnataka), gratuity liability.
- **Audit trail** of approvals, record changes and views of sensitive fields.

## Sign in (Clerk)

Sign-in uses **Clerk** (email and password, or Google). Clerk's session token is passed to Supabase as a third-party auth token, and the database maps the verified email in that token to an employee and role in the `app_logins` table.

| Login email | Role | Sees |
| --- | --- | --- |
| priya.kulkarni@sahyadritech.in | HR Admin | Everything, including salary, PAN, UAN and the audit trail |
| rahul.deshmukh@sahyadritech.in | Manager | Their reporting line; approves team leave (over 5 days goes on to HR) |
| neha.patil@sahyadritech.in | Employee | Their own record, leave, attendance and pay summary |

Create these users in the Clerk dashboard (Users → Create user) to use them. An email that isn't in `app_logins` can sign in to Clerk but sees no data.

Setup: in Clerk, activate the Supabase integration and add `{"email": "{{user.primary_email_address}}"}` to the session token. In Supabase, add Clerk under Authentication → Third-Party Auth. Then put the Clerk publishable key in `CLERK_PUBLISHABLE_KEY` in `index.html`.

## Database (Supabase)

- `supabase/schema.sql`: tables, Row Level Security policies and the leave-approval rules enforced in the database.
- `supabase/seed.sql`: the fictional sample company and the three demo logins.

How access is enforced:

- Salary and ID fields live in a separate `employee_sensitive` table that only HR (and the employee themself) can read.
- Only the last 4 digits of Aadhaar are stored.
- Managers can read and act on leave only for people in their reporting line. A database trigger blocks anyone approving their own leave, and sends long or maternity leave to HR.
- Every approval and change is written to `audit_log`, readable by HR only.
- The browser uses Supabase's publishable key, which is safe to ship. Access comes from the signed-in user and the policies above.

To set up your own copy, create a Supabase project, run `schema.sql` then `seed.sql` in the SQL editor, and put your project URL and publishable key at the top of the script in `index.html`.

## Run it

- Live on Vercel, which redeploys automatically on every push to `main`.
- Locally: open `index.html` in a browser (needs internet to reach Supabase).

## Notes

- All data is fictional sample data.
- Statutory rates, due dates and holidays are illustrative. Verify against current EPFO, ESIC and state notifications before real use.
