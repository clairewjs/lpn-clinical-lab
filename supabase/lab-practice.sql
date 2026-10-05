create table public.lab_practice_sessions (
 id uuid primary key default gen_random_uuid(),
 learner_id uuid not null references public.profiles(id) on delete cascade,
 evaluator_id uuid references public.profiles(id) on delete set null,
 skill_id text not null,
 skill_version text not null,
 mode text not null check(mode in ('self','peer')),
 status text not null default 'draft' check(status in ('draft','finished')),
 learner_name text not null,
 evaluator_name text,
 checklist jsonb not null,
 results jsonb not null default '{}'::jsonb check(jsonb_typeof(results)='object'),
 notes jsonb not null default '{}'::jsonb check(jsonb_typeof(notes)='object'),
 elapsed_seconds integer not null default 0 check(elapsed_seconds>=0),
 finished_at timestamptz,
 created_at timestamptz not null default now(),
 check(mode='peer' or evaluator_id is null)
);
create index lab_practice_learner_idx on public.lab_practice_sessions(learner_id);
create index lab_practice_evaluator_idx on public.lab_practice_sessions(evaluator_id);
alter table public.lab_practice_sessions enable row level security;
revoke all on public.lab_practice_sessions from anon,authenticated;
grant select on public.lab_practice_sessions to authenticated;
grant insert(id,learner_id,skill_id,skill_version,mode,learner_name,checklist) on public.lab_practice_sessions to authenticated;
grant update(results,notes,elapsed_seconds,status,finished_at) on public.lab_practice_sessions to authenticated;
create policy lab_practice_read on public.lab_practice_sessions for select to authenticated using (
 learner_id=(select auth.uid()) or evaluator_id=(select auth.uid()) or (select private.is_instructor())
);
create policy lab_practice_create on public.lab_practice_sessions for insert to authenticated with check (
 learner_id=(select auth.uid()) and evaluator_id is null and status='draft'
 and exists(select 1 from public.profiles where id=(select auth.uid()))
);
create policy lab_practice_rate on public.lab_practice_sessions for update to authenticated using (
 status='draft' and ((mode='self' and learner_id=(select auth.uid())) or (mode='peer' and evaluator_id=(select auth.uid())))
) with check (
 (mode='self' and learner_id=(select auth.uid())) or (mode='peer' and evaluator_id=(select auth.uid()))
);
-- The pairing capability is the unguessable session UUID, shared only by its learner.
-- The helper bypasses RLS only to claim that exact run; it verifies membership and identity.
create function private.join_lab_practice(p_session_id uuid)
returns uuid language plpgsql security definer set search_path='' as $$
declare caller uuid := auth.uid(); caller_name text; joined_id uuid;
begin
 if caller is null then raise exception 'Sign in to join peer practice'; end if;
 select display_name into caller_name from public.profiles where id=caller;
 if not found then raise exception 'A classroom profile is required'; end if;
 update public.lab_practice_sessions set evaluator_id=caller,evaluator_name=caller_name
 where id=p_session_id and mode='peer' and status='draft' and learner_id<>caller
 and (evaluator_id is null or evaluator_id=caller) returning id into joined_id;
 if joined_id is null then raise exception 'Pairing code is unavailable, already claimed, or belongs to your own practice'; end if;
 return joined_id;
end; $$;
revoke all on function private.join_lab_practice(uuid) from public,anon;
grant usage on schema private to authenticated;
grant execute on function private.join_lab_practice(uuid) to authenticated;
create function public.join_lab_practice(p_session_id uuid)
returns uuid language sql security invoker set search_path='' as $$
 select private.join_lab_practice(p_session_id);
$$;
revoke all on function public.join_lab_practice(uuid) from public,anon;
grant execute on function public.join_lab_practice(uuid) to authenticated;

create function private.validate_lab_practice()
returns trigger language plpgsql security invoker set search_path='' as $$
declare canonical jsonb; a jsonb; k text; v jsonb;
begin
 if TG_OP='INSERT' then
  select skill into canonical from public.clinical_content c
  cross join lateral jsonb_array_elements(c.payload->'labSkills') as skill
  where c.id='curriculum' and skill->>'id'=NEW.skill_id;
  if canonical is null then raise exception 'Unknown lab skill'; end if;
  NEW.checklist:=canonical;
  NEW.skill_version:=canonical->>'version';
  select display_name into NEW.learner_name from public.profiles where id=auth.uid();
 elsif NEW.results is distinct from OLD.results then
  for k,v in select * from jsonb_each(NEW.results) loop
   select action into a from jsonb_array_elements(NEW.checklist->'sections') as section
   cross join lateral jsonb_array_elements(section->'actions') as action where action->>'id'=k;
   if a is null or v #>> '{}' not in ('','done','missed','na') or jsonb_typeof(v)<>'string' then
    raise exception 'Invalid checklist result';
   end if;
   if v #>> '{}'='na' and not (a->>'conditional')::boolean then raise exception 'This action requires evaluation'; end if;
  end loop;
 end if;
 if NEW.status='finished' and TG_OP='UPDATE' then
  if NEW.elapsed_seconds<=0 then raise exception 'Start the practice timer before finishing'; end if;
  for a in select action from jsonb_array_elements(NEW.checklist->'sections') as section
   cross join lateral jsonb_array_elements(section->'actions') as action loop
   if coalesce(NEW.results->>(a->>'id'),'') not in ('done','na','missed') then raise exception 'Finish all checklist results before submitting'; end if;
  end loop;
  NEW.finished_at:=now();
 end if;
 return NEW;
end; $$;
revoke all on function private.validate_lab_practice() from public,anon,authenticated;
create trigger validate_lab_practice before insert or update of results,status on public.lab_practice_sessions for each row execute function private.validate_lab_practice();