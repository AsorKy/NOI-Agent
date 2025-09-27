-- N8N load to supabase buffer table    
create table if not exists buffer (
  id uuid primary key default gen_random_uuid(),
  file_name text not null,
  supabase_key text,
  ragflow_id text,
  up_status text check (up_status in ('uploaded', 'pending', 'failed')) not null,
  pross_status text check (pross_status in ('pending', 'processing', 'done', 'error')) not null,
  created_at timestamp with time zone default now()
);

-- N8N error buffer table (supabase uploads)
create table if not exists buffer_errors (
  id uuid primary key default gen_random_uuid(),
  file_name text not null,
  supabase_key text,
  error text not null,
  created_at timestamp with time zone default now()
);
