-- Create a table for public "profiles"
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  username varchar(24) not null unique,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc' :: text, now()) not null,

  -- username should be 3 to 24 characters long containing alphabets, numbers and underscores
  constraint username_validation check (username ~* '^[A-Za-z0-9_]{3,24}$')
);

create policy "Public profiles are viewable by everyone."
  on public.profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on public.profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on public.profiles for update
  using ( auth.uid() = id );

alter table public.profiles enable row level security;

create table if not exists public.messages (
    id uuid not null primary key default uuid_generate_v4(),
    profile_id uuid default auth.uid() references public.profiles(id) on delete cascade not null,
    content varchar(500) not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.messages is 'Holds individual messages.';

create policy "Public messages are viewable by everyone."
  on public.messages for select
  using ( true );

create policy "Everyone can insert a new message."
  on public.messages for select
  using ( true );

create policy "Users can update own message."
  on public.messages for update
  using ( auth.uid() = profile_id );

create policy "Users can delete own message."
  on public.messages for delete
  using ( auth.uid() = profile_id );

alter table public.messages enable row level security;

-- Function to create a new row in profiles table upon signup
-- Also copies the username value from metadata
create or replace function handle_new_user() returns trigger as $$
    begin
        insert into public.profiles(id, username)
        values(new.id, new.raw_user_meta_data->>'username');

        return new;
    end;
$$ language plpgsql security definer;

-- Trigger to call `handle_new_user` when new user signs up
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute function handle_new_user();

-- Set up Realtime!
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table public.messages;

-- Set up Storage!
insert into storage.buckets (id, name)
values ('avatars', 'avatars');

create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

create policy "Anyone can upload an avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' );
