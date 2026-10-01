-- Durgacure compliance calendar: shared Done / N/A ticks
-- Run once in Supabase → SQL Editor. Replace the emails with the partners who may tick.

create table if not exists public.compliance_status (
  key         text primary key,                 -- e.g. gstr3b_2026-11-20
  status      text not null check (status in ('done','na')),
  updated_by  text,
  updated_at  timestamptz not null default now()
);

alter table public.compliance_status enable row level security;

create or replace function public.dcl_is_partner() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'email', '') in (
    'partner1@example.com',
    'partner2@example.com',
    'partner3@example.com'
  );
$$;

create policy "partners read"   on public.compliance_status for select to authenticated using (public.dcl_is_partner());
create policy "partners insert" on public.compliance_status for insert to authenticated with check (public.dcl_is_partner());
create policy "partners update" on public.compliance_status for update to authenticated using (public.dcl_is_partner()) with check (public.dcl_is_partner());
create policy "partners delete" on public.compliance_status for delete to authenticated using (public.dcl_is_partner());

-- Live updates between partners' screens
alter publication supabase_realtime add table public.compliance_status;
