------------------------
-- Chat history table --
------------------------
create table if not exists n8n_chat_history(
  id uuid primary key default gen_random_uuid(),
  session_id text not null,
  message jsonb not null
); 

-----------------------------------------------
-- N8N error buffer table (supabase uploads) --
-----------------------------------------------
create table if not exists buffer_errors (
  id uuid primary key default gen_random_uuid(),
  file_name text not null,
  supabase_key text,
  error text not null,
  status text check (status in ('pending', 'solved')),
  created_at timestamp with time zone default now()
);

------------------------
-- N8N Metadata table --
------------------------
create table if not exists document_metadata(
  --id uuid primary key default gen_random_uuid(),
  document_id uuid primary key default gen_random_uuid(),  
  document_name text not null default 'NULL',
  document_url text not null default 'NULL',
  document_pages int,
  document_summary text,
  schema text,
  created_at timestamp with time zone default now(),
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info'
);

---------------------------------------
-- N8N load to supabase buffer table --
---------------------------------------   
create table if not exists buffer(
  id uuid primary key default gen_random_uuid(),
  document_id uuid default gen_random_uuid(),  
  buffer_error_id uuid default null,      
  file_name text default 'NULL',
  supabase_key text default 'NULL',
  up_status text check (up_status in ('uploaded', 'pending', 'failed')) default 'pending',
  up_drive_status text check (up_drive_status in ('uploaded', 'pending', 'failed')) default 'pending',
  pross_status text check (pross_status in ('pending', 'processing', 'done', 'error')) default 'pending',
  created_at timestamp with time zone default now(),
  last_updated timestamp with time zone default now(),
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (buffer_error_id) references buffer_errors(id) on delete set null 
);

-----------------------------------
-- N8N documents_vector_database --
-----------------------------------
create table if not exists document_vector(
  chunk_id uuid primary key default gen_random_uuid(),
  document_id uuid not null,
  buffer_id uuid not null,
  chunk_text text not null default 'NULL',
  metadata jsonb not null, 
  embedding vector(1536),
  created_at timestamp with time zone default now(), 
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info',
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (buffer_id) references buffer(id) on delete cascade
);


