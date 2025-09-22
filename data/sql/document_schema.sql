-- Enable vector data storage 
create extension if not exists vector;

--Document maint table 
create table documents (
  id uuid primary key,                     
  name text not null,                      
  uploaded_at timestamptz default now(),    
  total_chunks int default 0               
);

-- Chunk table 
create table document_chunks (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id) on delete cascade,
  chunk_id text not null,                  
  page_number int,
  text text,                               
  bbox jsonb,                             
  embedding vector(2000)                   
);

-- Search usefull index
create index on document_chunks (document_id);
create index on document_chunks (page_number);
create index on document_chunks using ivfflat (embedding vector_cosine_ops) with (lists = 100);