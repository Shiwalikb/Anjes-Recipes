-- Anje's Recipes: cloud sync setup.
-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.
-- Only signed-in accounts can read or change recipes. Recipe photos are stored
-- in a public bucket under random file names (viewable only by someone who has the exact link).

create table if not exists public.recipes (
  id      text primary key,
  data    jsonb,
  updated bigint  not null default 0,
  deleted boolean not null default false
);

alter table public.recipes enable row level security;
grant select, insert, update, delete on public.recipes to authenticated;
revoke all on public.recipes from anon;

drop policy if exists "signed-in can read recipes"   on public.recipes;
drop policy if exists "signed-in can add recipes"    on public.recipes;
drop policy if exists "signed-in can change recipes" on public.recipes;
drop policy if exists "signed-in can delete recipes" on public.recipes;
create policy "signed-in can read recipes"   on public.recipes for select to authenticated using (true);
create policy "signed-in can add recipes"    on public.recipes for insert to authenticated with check (true);
create policy "signed-in can change recipes" on public.recipes for update to authenticated using (true) with check (true);
create policy "signed-in can delete recipes" on public.recipes for delete to authenticated using (true);

-- photo storage
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

drop policy if exists "signed-in can see photo files"   on storage.objects;
drop policy if exists "signed-in can upload photos"     on storage.objects;
drop policy if exists "signed-in can replace photos"    on storage.objects;
drop policy if exists "signed-in can delete photos"     on storage.objects;
create policy "signed-in can see photo files" on storage.objects for select to authenticated using (bucket_id = 'photos');
create policy "signed-in can upload photos"   on storage.objects for insert to authenticated with check (bucket_id = 'photos');
create policy "signed-in can replace photos"  on storage.objects for update to authenticated using (bucket_id = 'photos');
create policy "signed-in can delete photos"   on storage.objects for delete to authenticated using (bucket_id = 'photos');
