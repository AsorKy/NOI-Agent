------------------------
-- Chat history table --
------------------------
create table if not exists n8n_chat_histories(
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
-- N8N database table --
------------------------
create table if not exists n8n_databases(
  id uuid primary key default gen_random_uuid(),
  db_name text not null,
  db_type text check(db_type in ('well_history', 'reports', 'noi-submittions', 'noi-resubmittions', 'chat_history', 'n8n_chat_history', 'analytics')) not null,
  created_at timestamp with time zone default now(),
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived', 'deleted')) default 'active_info'
);

------------------------
-- N8N Metadata table --
------------------------
create table if not exists document_metadata(
  --id uuid primary key default gen_random_uuid(),
  document_id text primary key not null,
  database_id uuid not null,  
  document_name text not null default 'NULL',
  document_url text not null default 'NULL',
  document_type text check(document_type in ('well_history', 'reports', 'submittion', 'resubmittion', 'analytics', 'other')) default 'other',
  document_pages int,
  document_summary text,
  schema text,
  created_at timestamp with time zone default now(),
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info',
  -- Foreign Key Definitions
  foreign key (database_id) references n8n_databases(id) on delete cascade
);

---------------------------------------
-- N8N load to supabase buffer table --
---------------------------------------   
create table if not exists buffer (
  id uuid default gen_random_uuid(),--key default gen_random_uuid(),
  document_id text primary key not null,  --default gen_random_uuid(),  
  database_id uuid not null,
  buffer_error_id uuid,      
  file_name text default 'NULL',
  supabase_key text default 'NULL',
  up_status text check (up_status in ('uploaded', 'pending', 'failed')) default 'pending',
  up_drive_status text check (up_drive_status in ('uploaded', 'pending', 'failed', 'deleted')) default 'pending',
  pross_status text check (pross_status in ('pending', 'processing', 'done', 'error')) default 'pending',
  created_at timestamp with time zone default now(),
  last_updated timestamp with time zone default now(),
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (database_id) references n8n_databases(id) on delete cascade,
  foreign key (buffer_error_id) references buffer_errors(id) on delete set null -- Set to NULL if error is deleted
);

-----------------------------------
-- N8N documents_vector_database --
-----------------------------------
create table if not exists document_vector(
  chunk_id uuid primary key default gen_random_uuid(),
  chunk_text text not null default 'NULL',
  metadata jsonb not null, 
  embedding vector(768)
);

--------------------------------------------
-- N8N documents_vector_database-archived --
--------------------------------------------
create table if not exists document_vector_archived(
  chunk_id uuid primary key default gen_random_uuid(),
  chunk_text text not null default 'NULL',
  metadata jsonb not null, 
  embedding vector(768)
);


--------------------------------------
-- Embedding table - metadata pivot --
--------------------------------------

create table if not exists vector_to_metadata(
  chunk_id uuid primary key,
  chunk_archived_id uuid,
  document_id text not null,
  created_at timestamp with time zone default now(), 
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info',
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (chunk_id) references document_vector(chunk_id),
  foreign key (chunk_archived_id) references document_vector_archived(chunk_id)
);


-----------------------------
-- N8N documents row table --
-----------------------------
create table if not exists document_spreadsheet_rows(
  row_id uuid primary key default gen_random_uuid(),
  document_id text not null,
  database_id uuid not null default gen_random_uuid(),
  spreadsheet_type text check(spreadsheet_type in ('financial', 'payroll', 'market statistics', 'planning', 'other')) default 'other',
  sheet_name text not null default 'NULL',
  row_data jsonb not null,
  created_at timestamp with time zone default now(), 
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info',
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (database_id) references n8n_databases(id) on delete cascade
);

--------------------------------
-- Auxiliary schema functions --
--------------------------------

-- Ejecutar en Supabase SQL Editor
ALTER TABLE document_vector
    DROP CONSTRAINT document_vector_chunk_id_fkey;

-- Ejecutar en Supabase SQL Editor

-- Primero, eliminar la FK del pivote que apunta a documents_vector (si existe)
ALTER TABLE vector_to_metadata
    DROP CONSTRAINT IF EXISTS vector_to_metadata_chunk_id_fkey;

-- Segundo, crear la FK CORRECTA: El pivote debe apuntar al vector store
ALTER TABLE vector_to_metadata
    ADD CONSTRAINT vector_to_metadata_chunk_id_fkey
    FOREIGN KEY (chunk_id)
    REFERENCES document_vector(chunk_id) ON DELETE CASCADE;

----------------------------------
-- Time stamp updates functions --
----------------------------------

create or replace function update_last_modified_timestamp()
returns trigger as $$
begin 
  NEW.last_updated = now()
  return new;
end  
  $$ language plpgsql;

-- metadata lastupdate function -- 
create or replace trigger last_modified_trigger
before update on document_metadata
for each   

