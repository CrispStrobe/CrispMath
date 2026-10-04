set role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
insert into public.user_sync_data (user_id, app_state, updated_at) values
 ('11111111-1111-1111-1111-111111111111', '{}', '2000-01-01T00:00:00Z');
select set_config('request.jwt.claim.sub', '22222222-2222-2222-2222-222222222222', false);
do $$ begin
  if (select count(*) from public.user_sync_data) <> 0 then
    raise exception 'Other user backup was readable';
  end if;
  begin
    insert into public.user_sync_data (user_id, app_state, updated_at) values
      ('11111111-1111-1111-1111-111111111111', '{}', now());
    raise exception 'Other user backup was writable';
  exception when insufficient_privilege then null;
  end;
  update public.user_sync_data set app_state = '{"changed":true}'
    where user_id = '11111111-1111-1111-1111-111111111111';
  if found then raise exception 'Other user backup was updated'; end if;
end $$;
insert into public.user_sync_data (user_id, app_state, updated_at) values
 ('22222222-2222-2222-2222-222222222222', '{}', '2000-01-01T00:00:00Z');
do $$ begin
  update public.user_sync_data set revision = 1
    where user_id = '22222222-2222-2222-2222-222222222222'
      and revision = 0;
  if not found then raise exception 'Expected revision update failed'; end if;
  update public.user_sync_data set app_state = '{"lost":true}'
    where user_id = '22222222-2222-2222-2222-222222222222'
      and revision = 0;
  if found then raise exception 'Stale revision overwrote the backup'; end if;
  begin
    insert into public.user_sync_data (user_id, app_state, updated_at) values
      ('22222222-2222-2222-2222-222222222222', '{}', now());
    raise exception 'Concurrent first upload overwrote a backup';
  exception when unique_violation then null;
  end;
end $$;
reset role;
set role anon;
do $$ begin
  begin
    perform count(*) from public.user_sync_data;
    raise exception 'Anonymous user could read backups';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;
