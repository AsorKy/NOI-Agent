-- N8N load to supabase buffer table    
create table if not exists buffer (
  id uuid primary key default gen_random_uuid(),
  file_name text default 'NULL',
  supabase_key text default 'NULL',
  ragflow_id text default 'NULL',
  up_status text check (up_status in ('uploaded', 'pending', 'failed')) default 'NULL',
  up_ragflow_status text check (up_ragflow_status in ('uploaded', 'pending', 'failed')) default 'NULL',
  pross_status text check (pross_status in ('pending', 'processing', 'done', 'error')) default 'NULL',
  created_at timestamp with time zone default now()
);

-- N8N error buffer table (supabase uploads)
create table if not exists buffer_errors (
  id uuid primary key default gen_random_uuid(),
  file_name text not null,
  supabase_key text,
  error text not null,
  status text check (status in ('pending', 'solved'))
  created_at timestamp with time zone default now()
);
