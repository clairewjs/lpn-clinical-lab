-- Claire's LPN Clinical Case Lab, one classroom per Supabase project.
-- Run once in a NEW Supabase project's SQL Editor. Never run against an unrelated database.
begin;
create table public.invitations (
 email text primary key check (email = lower(email) and length(email) <= 320),
 display_name text not null check (length(display_name) between 1 and 120),
 created_at timestamptz not null default now()
);
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null,
 role text not null default 'student' check (role in ('student','instructor')),
 created_at timestamptz not null default now()
);
create function public.is_instructor() returns boolean language sql stable security definer
set search_path = '' as $$
 select exists(select 1 from public.profiles where id=(select auth.uid()) and role='instructor');
$$;
revoke all on function public.is_instructor() from public, anon;
grant execute on function public.is_instructor() to authenticated;
create function public.handle_invited_user() returns trigger language plpgsql security definer
set search_path = '' as $$
declare invited_name text;
begin
 select display_name into invited_name from public.invitations where email=lower(new.email);
 if invited_name is null then raise exception 'This email has not been invited to this classroom.'; end if;
 insert into public.profiles(id,display_name,role) values(new.id,invited_name,'student');
 return new;
end;
$$;
revoke all on function public.handle_invited_user() from public, anon, authenticated;
create trigger on_lpn_auth_user_created after insert on auth.users for each row execute function public.handle_invited_user();
create table public.submissions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 case_id text not null check (case_id ~ '^L[1-4]-(0[1-9]|1[0-2])$'),
 answers jsonb not null default '{}'::jsonb check (jsonb_typeof(answers)='object' and octet_length(answers::text)<1000000),
 status text not null default 'draft' check (status in ('draft','submitted')),
 updated_at timestamptz not null default now(),
 unique(user_id,case_id)
);
create table public.reviews (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 case_id text not null check (case_id ~ '^L[1-4]-(0[1-9]|1[0-2])$'),
 feedback text not null default '' check (length(feedback)<50000),
 criteria jsonb not null default '{}'::jsonb,
 lab_outcome text not null default 'Not assessed' check (lab_outcome in ('Not assessed','Pass','Further practice required','Reassessment required','Theory reviewed','Further theory review needed')),
 released boolean not null default false,
 updated_by uuid references public.profiles(id),
 updated_at timestamptz not null default now(),
 unique(user_id,case_id)
);
create table public.assignments (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 case_id text not null check (case_id ~ '^L[1-4]-(0[1-9]|1[0-2])$'),
 due_date date,
 unique(user_id,case_id)
);
create function public.set_submission_time() returns trigger language plpgsql set search_path='' as $$
begin new.updated_at=now(); return new; end;
$$;
create trigger submission_time before insert or update on public.submissions for each row execute function public.set_submission_time();
create function public.set_review_audit() returns trigger language plpgsql set search_path='' as $$
begin new.updated_at=now(); new.updated_by=auth.uid(); return new; end;
$$;
create trigger review_audit before insert or update on public.reviews for each row execute function public.set_review_audit();
alter table public.invitations enable row level security;
alter table public.profiles enable row level security;
alter table public.submissions enable row level security;
alter table public.reviews enable row level security;
alter table public.assignments enable row level security;
revoke all on public.invitations,public.profiles,public.submissions,public.reviews,public.assignments from anon,authenticated;
grant select,insert,delete on public.invitations to authenticated;
grant select on public.profiles to authenticated;
grant select,insert,update on public.submissions to authenticated;
grant select,insert,update on public.reviews to authenticated;
grant select,insert,update,delete on public.assignments to authenticated;
create policy invitation_instructor_select on public.invitations for select to authenticated using(public.is_instructor());
create policy invitation_instructor_insert on public.invitations for insert to authenticated with check(public.is_instructor());
create policy invitation_instructor_delete on public.invitations for delete to authenticated using(public.is_instructor());
create policy profile_read on public.profiles for select to authenticated using(id=(select auth.uid()) or public.is_instructor());
-- No profile write policy or grant: users cannot promote themselves or change roles.
create policy submission_read on public.submissions for select to authenticated using(user_id=(select auth.uid()) or public.is_instructor());
create policy submission_insert on public.submissions for insert to authenticated with check(user_id=(select auth.uid()));
create policy submission_update on public.submissions for update to authenticated using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));
create policy review_read on public.reviews for select to authenticated using(public.is_instructor() or (user_id=(select auth.uid()) and released));
create policy review_insert on public.reviews for insert to authenticated with check(public.is_instructor());
create policy review_update on public.reviews for update to authenticated using(public.is_instructor()) with check(public.is_instructor());
create policy assignment_read on public.assignments for select to authenticated using(user_id=(select auth.uid()) or public.is_instructor());
create policy assignment_insert on public.assignments for insert to authenticated with check(public.is_instructor());
create policy assignment_update on public.assignments for update to authenticated using(public.is_instructor()) with check(public.is_instructor());
create policy assignment_delete on public.assignments for delete to authenticated using(public.is_instructor());
create index submissions_user_idx on public.submissions(user_id);
create index reviews_user_idx on public.reviews(user_id);
create index assignments_user_idx on public.assignments(user_id);
commit;
