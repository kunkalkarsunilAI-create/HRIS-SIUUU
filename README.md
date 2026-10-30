# Sahyadri HRIS

A demo HR Information System (core HRMS) built for the *New Age HR Applications using AI* course, following section 10 of the guide "Claude Skills for HR Tech".

It is a single `index.html` file with no build step and no server. Open it in any browser.

## Modules

- **Employee master** with search, filters, pagination and a validated add/edit form. PAN, UAN and salary are visible to HR Admin only; only the last 4 digits of Aadhaar are stored.
- **Org chart** built from reporting lines.
- **Leave and attendance**: balances, apply, manager approval (over 5 days and maternity leave go on to HR), monthly attendance grid, check-in/out, holiday calendar.
- **Payroll inputs**: monthly figures adjusted for loss-of-pay days, with PF, ESI and professional tax.
- **HR letters**: offer, confirmation, promotion, relieving and experience letters on letterhead.
- **Compliance**: PF ECR in EPFO upload format, ESI, professional tax (Maharashtra and Karnataka), gratuity liability.
- **Audit trail** of approvals, record changes and views of sensitive fields.

## Roles

Switch with the "Viewing as" menu: HR Admin (Priya Kulkarni), Manager (Rahul Deshmukh), Employee (Neha Patil).

## Run it

- Locally: open `index.html` in a browser.
- Online with GitHub Pages: repository **Settings → Pages → Deploy from a branch → `main` / root → Save**. The site appears at `https://<your-username>.github.io/<repo-name>/`.

## Notes

- All data is fictional sample data and is saved only in the viewer's browser (localStorage). "Reset demo data" restores it.
- Statutory rates, due dates and holidays are illustrative. Verify against current EPFO, ESIC and state notifications before real use.
