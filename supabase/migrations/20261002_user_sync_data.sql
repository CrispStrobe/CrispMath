-- Apply to the selected project after checking its existing schema.
-- Public client keys rely on these per-user row policies.
create table if not exists public.user_sync_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  app_state text not null check (octet_length(app_state) <= 16777216),
  revision bigint not null default 0 check (revision >= 0),
  updated_at timestamptz not null default now()
);
alter table public.user_sync_data add column if not exists revision bigint not null default 0;
alter table public.user_sync_data enable row level security;
revoke all on public.user_sync_data from anon;
grant select, insert, update on public.user_sync_data to authenticated;
drop policy if exists crisp_sync_read on public.user_sync_data;
create policy crisp_sync_read on public.user_sync_data for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists crisp_sync_insert on public.user_sync_data;
create policy crisp_sync_insert on public.user_sync_data for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists crisp_sync_update on public.user_sync_data;
create policy crisp_sync_update on public.user_sync_data for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
