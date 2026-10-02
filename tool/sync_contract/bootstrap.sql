create role anon nologin;
create role authenticated nologin;
create schema auth;
create table auth.users (id uuid primary key);
create function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
grant usage on schema auth, public to authenticated;
grant execute on function auth.uid() to authenticated;
insert into auth.users values
 ('11111111-1111-1111-1111-111111111111'),
 ('22222222-2222-2222-2222-222222222222');
