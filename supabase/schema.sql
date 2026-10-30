-- Sahyadri HRIS: Supabase schema (final state of the applied migrations)
-- Run in the Supabase SQL editor on a fresh project, then run seed.sql.

create sequence public.emp_seq start 16;
create sequence public.leave_seq start 111;

create table public.employees (
  id text primary key default ('EMP' || lpad(nextval('public.emp_seq')::text, 3, '0')),
  name text not null check (length(name) >= 3),
  email text not null unique,
  phone text not null check (phone ~ '^[6-9][0-9]{9}$'),
  designation text not null,
  dept text not null,
  manager_id text references public.employees(id),
  doj date not null,
  location text not null check (location in ('Pune','Bengaluru')),
  type text not null check (type in ('Full-time','Contract','Intern')),
  status text not null check (status in ('Active','Probation','Notice','Exited')),
  lwd date,
  el_carry numeric not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);
create index on public.employees(manager_id);

-- Sensitive fields live in a separate table: HR reads all, an employee reads only their own row
create table public.employee_sensitive (
  employee_id text primary key references public.employees(id) on delete cascade,
  ctc numeric not null check (ctc > 0),
  gender text not null check (gender in ('F','M','O')),
  pan text not null check (pan ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'),
  uan text check (uan ~ '^[0-9]{12}$'),
  aadhaar_last4 text not null check (aadhaar_last4 ~ '^[0-9]{4}$'),  -- full Aadhaar is never stored
  bank_last4 text check (bank_last4 ~ '^[0-9]{4}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);

-- Links a Supabase Auth login to an employee and a role
create table public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  employee_id text not null unique references public.employees(id) on delete cascade,
  role text not null check (role in ('employee','manager','hr_admin')),
  created_at timestamptz not null default now()
);

create table public.leave_requests (
  id text primary key default ('LV' || nextval('public.leave_seq')::text),
  employee_id text not null references public.employees(id) on delete cascade,
  type text not null check (type in ('CL','SL','EL','ML','PL','LOP')),
  from_date date not null,
  to_date date not null,
  status text not null check (status in ('Pending manager','Pending HR','Approved','Rejected','Withdrawn')),
  reason text not null,
  applied_on date not null default current_date,
  history jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid(),
  check (to_date >= from_date)
);
create index on public.leave_requests(employee_id);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  employee_id text not null references public.employees(id) on delete cascade,
  name text not null,
  kind text not null,
  doc_date date not null default current_date,
  status text not null check (status in ('Issued','Verified','Pending','Received')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid()
);
create index on public.documents(employee_id);

create table public.attendance (
  employee_id text not null references public.employees(id) on delete cascade,
  day date not null,
  check_in text,
  check_out text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid(),
  primary key (employee_id, day)
);

-- ---------- Role helpers, in a private schema the public API cannot call ----------
create schema app;
grant usage on schema app to authenticated;
revoke all on schema app from anon, public;

create function app.my_emp_id() returns text language sql stable security definer set search_path = '' as
$$ select employee_id from public.user_roles where user_id = auth.uid() $$;

create function app.my_role() returns text language sql stable security definer set search_path = '' as
$$ select role from public.user_roles where user_id = auth.uid() $$;

create function app.is_hr() returns boolean language sql stable security definer set search_path = '' as
$$ select coalesce((select role = 'hr_admin' from public.user_roles where user_id = auth.uid()), false) $$;

-- true when emp reports to the signed-in person, directly or further down
create function app.in_my_team(emp text) returns boolean language sql stable security definer set search_path = '' as
$$
  with recursive t as (
    select e.id from public.employees e where e.manager_id = app.my_emp_id()
    union
    select e.id from public.employees e join t on e.manager_id = t.id
  ) select exists (select 1 from t where t.id = emp)
$$;

create table public.audit_log (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  by_employee text not null default app.my_emp_id() references public.employees(id),
  action text not null
);
create index on public.audit_log(at desc);

-- ---------- updated_at ----------
create function public.touch_updated_at() returns trigger language plpgsql set search_path = '' as
$$ begin new.updated_at := now(); return new; end $$;
create trigger t_emp before update on public.employees for each row execute function public.touch_updated_at();
create trigger t_sen before update on public.employee_sensitive for each row execute function public.touch_updated_at();
create trigger t_lv before update on public.leave_requests for each row execute function public.touch_updated_at();
create trigger t_doc before update on public.documents for each row execute function public.touch_updated_at();
create trigger t_att before update on public.attendance for each row execute function public.touch_updated_at();

-- ---------- Leave approval rules, enforced by the database ----------
create function app.guard_leave_update() returns trigger language plpgsql security definer set search_path = '' as
$$
begin
  if app.is_hr() then return new; end if;
  if new.employee_id <> old.employee_id or new.type <> old.type or new.from_date <> old.from_date or new.to_date <> old.to_date then
    raise exception 'Only HR can change leave dates or type';
  end if;
  if app.my_role() = 'manager' and app.in_my_team(old.employee_id) then
    if old.status <> 'Pending manager' or new.status not in ('Pending HR','Approved','Rejected') then
      raise exception 'Managers can only act on requests pending manager approval';
    end if;
    if new.status = 'Approved' and (old.type = 'ML' or (old.to_date - old.from_date) >= 5) then
      raise exception 'Leave over 5 days and maternity leave need HR approval';
    end if;
    return new;
  end if;
  if old.employee_id = app.my_emp_id() then
    if old.status not like 'Pending%' or new.status <> 'Withdrawn' then
      raise exception 'You can only withdraw your own pending requests';
    end if;
    return new;
  end if;
  raise exception 'Not allowed';
end $$;
create trigger t_lv_guard before update on public.leave_requests for each row execute function app.guard_leave_update();

-- ---------- Row Level Security on every table ----------
alter table public.employees enable row level security;
alter table public.employee_sensitive enable row level security;
alter table public.user_roles enable row level security;
alter table public.leave_requests enable row level security;
alter table public.documents enable row level security;
alter table public.attendance enable row level security;
alter table public.audit_log enable row level security;

-- employees: work directory visible to signed-in staff; only HR writes
create policy emp_read on public.employees for select to authenticated using (true);
create policy emp_hr_ins on public.employees for insert to authenticated with check ((select app.is_hr()));
create policy emp_hr_upd on public.employees for update to authenticated using ((select app.is_hr())) with check ((select app.is_hr()));

-- sensitive: HR all; employee own row, read-only
create policy sen_read on public.employee_sensitive for select to authenticated
  using ((select app.is_hr()) or employee_id = (select app.my_emp_id()));
create policy sen_hr_ins on public.employee_sensitive for insert to authenticated with check ((select app.is_hr()));
create policy sen_hr_upd on public.employee_sensitive for update to authenticated using ((select app.is_hr())) with check ((select app.is_hr()));

create policy roles_read on public.user_roles for select to authenticated
  using (user_id = (select auth.uid()) or (select app.is_hr()));

-- leave: own, team (managers), all (HR)
create policy lv_read on public.leave_requests for select to authenticated
  using ((select app.is_hr()) or employee_id = (select app.my_emp_id()) or app.in_my_team(employee_id));
create policy lv_ins on public.leave_requests for insert to authenticated
  with check (employee_id = (select app.my_emp_id()) and status in ('Pending manager','Pending HR'));
create policy lv_upd on public.leave_requests for update to authenticated
  using ((select app.is_hr()) or employee_id = (select app.my_emp_id()) or app.in_my_team(employee_id));

-- documents: HR all; employee own (their uploads start as Pending)
create policy doc_read on public.documents for select to authenticated
  using ((select app.is_hr()) or employee_id = (select app.my_emp_id()));
create policy doc_ins on public.documents for insert to authenticated
  with check ((select app.is_hr()) or (employee_id = (select app.my_emp_id()) and status = 'Pending'));
create policy doc_upd on public.documents for update to authenticated using ((select app.is_hr())) with check ((select app.is_hr()));

-- attendance: read own/team/all; write only your own row for today
create policy att_read on public.attendance for select to authenticated
  using ((select app.is_hr()) or employee_id = (select app.my_emp_id()) or app.in_my_team(employee_id));
create policy att_ins on public.attendance for insert to authenticated
  with check (employee_id = (select app.my_emp_id()) and day = current_date);
create policy att_upd on public.attendance for update to authenticated
  using (employee_id = (select app.my_emp_id()) and day = current_date)
  with check (employee_id = (select app.my_emp_id()) and day = current_date);

-- audit: anyone signed in appends as themself; only HR reads
create policy aud_ins on public.audit_log for insert to authenticated with check (by_employee = (select app.my_emp_id()));
create policy aud_read on public.audit_log for select to authenticated using ((select app.is_hr()));

revoke execute on all functions in schema app from public, anon;
grant execute on function app.my_emp_id(), app.my_role(), app.is_hr(), app.in_my_team(text) to authenticated;
revoke execute on function app.guard_leave_update() from authenticated;
revoke execute on function public.touch_updated_at() from public, anon, authenticated;
revoke all on all tables in schema public from anon;
