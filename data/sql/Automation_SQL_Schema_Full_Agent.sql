--======================================================================================================================================================
---------------------------------------------------------------- n8n native development ----------------------------------------------------------------
--======================================================================================================================================================

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
  file_name text not null default 'NULL',
  supabase_key text default 'NULL',
  ragflow_id text default 'NULL',
  up_status text check (up_status in ('uploaded', 'pending', 'failed', 'deleted')) default 'NULL',
  up_ragflow_status text check (up_ragflow_status in ('uploaded', 'pending', 'failed', 'deleted')) default 'NULL',
  pross_status text check (pross_status in ('pending', 'processing', 'done', 'error')) default 'NULL',
  error text ,
  created_at timestamp with time zone default now()
);

------------------------
-- N8N database table --
------------------------
create table if not exists n8n_databases(
  id uuid primary key default gen_random_uuid(),
  ragflow_db_id text not null,
  db_name text not null,
  db_type text check(db_type in ('well_history', 'reports', 'noi-submittions', 'noi-resubmittions', 'chat_history', 'n8n_chat_history', 'analytics', 'other')) not null,
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
  ragflow_id text not null default 'NULL',
  database_id uuid,  
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
  id uuid default gen_random_uuid(),
  document_id text primary key not null default 'NULL',
  supabase_key text default 'NULL',
  ragflow_id text not null default 'NULL',   
  database_id uuid not null,
  buffer_error_id uuid,      
  file_name text default 'NULL',
  up_status text check (up_status in ('uploaded', 'pending', 'failed', 'deleted')) default 'pending',
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
  database_id uuid not null,
  spreadsheet_type text check(spreadsheet_type in ('financial', 'analytical', 'report', 'planning', 'engineering_information', 'accountability', 'submission_reports', 'other')) default 'other',
  sheet_name text not null default 'NULL',
  row_data jsonb not null,
  created_at timestamp with time zone default now(), 
  last_updated timestamp with time zone default now(),
  current_status varchar(100) not null check(current_status in('active_info','archived','deleted')) default 'active_info',
  -- Foreign Key Definitions
  foreign key (document_id) references document_metadata(document_id) on delete cascade,
  foreign key (database_id) references n8n_databases(id) on delete cascade
);


--======================================================================================================================================================
------------------------------------------------------- Ragflow native development (SQL Metadata)-------------------------------------------------------
--======================================================================================================================================================

-- =====================================================================================
-- Translation of RAGFlow Relational Schema (Python ORM to SQL)
-- Based on Knowledgebase, Document, File, File2Document, Task, Dialog, and Conversation models.
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- TABLE: knowledgebase
-- Stores information about knowledge bases (Datasets).
-- -------------------------------------------------------------------------------------
create table if not exists knowledgebase (
    id varchar(32) primary key not null,          
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    --------
    tenant_id varchar(32) not null,               
    name varchar(128) not null,                  
    language varchar(32) null default 'English',  
    description text null,                       
    embd_id varchar(128) not null,               
    permission varchar(16) not null default 'me', 
    created_by varchar(32) not null,           
    doc_num int default 0,                        
    token_num int default 0,                      
    chunk_num int default 0,                      
    similarity_threshold float default 0.2,      
    vector_similarity_weight float default 0.3,  
    parser_id varchar(32) not null default 'naive', 
    parser_config text not null default '{"pages": [[1, 1000000]]}', 
    pagerank int default 0,                       
    status varchar(1) null default '1'            
);

-- Indexes for knowledgebase table (based on index=True)
create index idx_kb_tenant_id on knowledgebase (tenant_id);
create index idx_kb_name on knowledgebase (name);
create index idx_kb_language on knowledgebase (language);
create index idx_kb_embd_id on knowledgebase (embd_id);
create index idx_kb_permission on knowledgebase (permission);
create index idx_kb_created_by on knowledgebase (created_by);
create index idx_kb_doc_num on knowledgebase (doc_num);
create index idx_kb_token_num on knowledgebase (token_num);
create index idx_kb_chunk_num on knowledgebase (chunk_num);
create index idx_kb_similarity_threshold on knowledgebase (similarity_threshold);
create index idx_kb_vector_similarity_weight on knowledgebase (vector_similarity_weight);
create index idx_kb_parser_id on knowledgebase (parser_id);
create index idx_kb_status on knowledgebase (status);


-- -------------------------------------------------------------------------------------
-- TABLE: document
-- Stores metadata about each processed document.
-- -------------------------------------------------------------------------------------
create table if not exists document (
    id varchar(32) primary key not null,  
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    --------            
    thumbnail text null,                             
    kb_id varchar(32) not null,                     
    parser_id varchar(32) not null,                 
    parser_config text not null default '{"pages": [[1, 1000000]]}',
    source_type varchar(128) not null default 'local', 
    type varchar(32) not null,                       
    created_by varchar(32) not null,               
    name varchar(255) null,                         
    location varchar(255) null,                      
    size int default 0,                              
    token_num int default 0,                         
    chunk_num int default 0,                       
    progress float default 0,                        
    progress_msg text null default '',            
    process_begin_at datetime null,               
    process_duration float default 0,            
    meta_fields text null default '{}',            
    suffix varchar(32) not null,                    
    run varchar(1) null default '0',               
    status varchar(1) null default '1'             
);


-- Indexes for document table (based on index=True)
create index idx_doc_kb_id on document (kb_id);
create index idx_doc_parser_id on document (parser_id);
create index idx_doc_source_type on document (source_type);
create index idx_doc_type on document (type);
create index idx_doc_created_by on document (created_by);
create index idx_doc_name on document (name);
create index idx_doc_location on document (location);
create index idx_doc_size on document (size);
create index idx_doc_token_num on document (token_num);
create index idx_doc_chunk_num on document (chunk_num);
create index idx_doc_progress on document (progress);
create index idx_doc_process_begin_at on document (process_begin_at);
create index idx_doc_suffix on document (suffix);
create index idx_doc_run on document (run);
create index idx_doc_status on document (status);

-- -------------------------------------------------------------------------------------
-- TABLE: file
-- Stores information about uploaded files and folders.
-- -------------------------------------------------------------------------------------
create table if not exists file (
    id varchar(32) primary key not null, 
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    ---         
    parent_id varchar(32) not null,               
    tenant_id varchar(32) not null,               
    created_by varchar(32) not null,              
    name varchar(255) not null,                  
    location varchar(255) null,                   
    size int default 0,                           
    type varchar(32) not null,                    
    source_type varchar(128) not null default ''  
);

-- Indexes for file table
create index idx_file_parent_id ON file (parent_id);
create index idx_file_tenant_id ON file (tenant_id);
create index idx_file_created_by ON file (created_by);
create index idx_file_name ON file (name);
create index idx_file_location ON file (location);
create index idx_file_size ON file (size);
create index idx_file_type ON file (type);
create index idx_file_source_type ON file (source_type);


-- -------------------------------------------------------------------------------------
-- TABLE: file2document
-- Maps files to their corresponding processed documents (Many-to-Many or One-to-One).
-- -------------------------------------------------------------------------------------
create table if not exists file2document (
    id varchar(32) primary key not null,         
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    --- 
    file_id varchar(32) null,                     
    document_id varchar(32) null                 
);

-- Indexes for file2document table
create index idx_f2d_file_id on file2document (file_id);
create index idx_f2d_document_id on file2document (document_id);


-- -------------------------------------------------------------------------------------
-- TABLE: task
-- Represents processing tasks for documents.
-- Defines the table that stores the metadata related with the document embeddings, it 
-- relates document-chunk-embedding information
-- -------------------------------------------------------------------------------------
create table if not exists task (
    id varchar(32) PRIMARY KEY not null,  
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    ---         
    doc_id varchar(32) not null,                  
    from_page int default 0,                    
    to_page int default 100000000,                
    task_type varchar(32) not null default '',    
    priority int default 0,                      
    begin_at datetime null,                       
    process_duration float default 0,            
    progress float default 0,                     
    progress_msg text null default '',            
    retry_count int default 0,                    
    digest text null default '',                  
    chunk_ids text null default ''                
);


-- Indexes for task table
create index idx_task_doc_id on task (doc_id);
create index idx_task_begin_at on task (begin_at);
create index idx_task_progress on task (progress);


-- -------------------------------------------------------------------------------------
-- TABLE: dialog
-- Defines configurations for chatbot applications/dialogs.
-- -------------------------------------------------------------------------------------
create table if not exists dialog (
    id varchar(32) primary key NOT null,    
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    ---        
    tenant_id varchar(32) NOT null,               
    name varchar(255) null,                      
    description TEXT null,                        
    icon TEXT null,                               
    language varchar(32) null default 'English',  
    llm_id varchar(128) NOT null,                 
    llm_setting TEXT NOT null default '{"temperature": 0.1, "top_p": 0.3, "frequency_penalty": 0.7, "presence_penalty": 0.4, "max_tokens": 512}', 
    prompt_type varchar(16) NOT null default 'simple', 
    prompt_config TEXT NOT null default '{"system": "", "prologue": "Hi! I''m your assistant. What can I do for you?", "parameters": [], "empty_response": "Sorry! No relevant content was found in the knowledge base!"}', 
    meta_data_filter TEXT null default '{}',      
    similarity_threshold FLOAT default 0.2,       
    vector_similarity_weight FLOAT default 0.3,   
    top_n INT default 6,                          
    top_k INT default 1024,                       
    do_refer varchar(1) NOT null default '1',     
    rerank_id varchar(128) NOT null,              
    kb_ids TEXT NOT null default '[]',            
    status varchar(1) null default '1'            
);

-- Indexes for dialog table
create index idx_dialog_tenant_id ON dialog (tenant_id);
create index idx_dialog_name ON dialog (name);
create index idx_dialog_language ON dialog (language);
create index idx_dialog_prompt_type ON dialog (prompt_type);
create index idx_dialog_status ON dialog (status);


-- -------------------------------------------------------------------------------------
-- TABLE: conversation
-- Stores the history of messages within a dialog session.
-- -------------------------------------------------------------------------------------
create table if not exists conversation (
    id varchar(32) primary key not null,
    --timing
    create_date timestamp default now(),
    update_date timestamp default now()
    ---            
    dialog_id varchar(32) not null,               
    name varchar(255) null,                       
    message text null,                            
    reference text null DEFAULT '[]',             
    user_id varchar(255) null                     
);

-- Indexes for conversation table
create index idx_conv_dialog_id on conversation (dialog_id);
create index idx_conv_name on conversation (name);
create index idx_conv_user_id on conversation (user_id);



-- -------------------------------------------------------------------------------------
-- DEFINITION OF FOREIGN KEYS
-- Enforce relationships between tables.
-- -------------------------------------------------------------------------------------

-- Foreign Key: document(kb_id) -> knowledgebase(id)
-- Note: Adjusted document.kb_id to VARCHAR(32) for compatibility.
alter table document 
add constraint fk_document_knowledgebase 
foreign key (kb_id) 
references knowledgebase (id)
on delete cascade; -- Optional: defines behavior when a knowledgebase is deleted.

-- foreign key: file2document(file_id) -> file(id)
alter table file2document
add constraint fk_file2document_file
foreign key (file_id)
references file (id)
on delete set null; -- Optional: Set file_id to NULL if the file is deleted.

-- foreign key: file2document(document_id) -> document(id)
alter table file2document
add constraint fk_file2document_document
foreign key (document_id)
references document (id)
on delete set null; -- Optional: Set document_id to NULL if the document is deleted.

-- foreign key: task(doc_id) -> document(id)
alter table task
add constraint fk_task_document
foreign key (doc_id)
references document (id)
on delete cascade; -- Optional: delete tasks if the associated document is deleted.

-- foreign key: conversation(dialog_id) -> dialog(id)
alter table conversation
add constraint fk_conversation_dialog
foreign key (dialog_id)
references dialog (id)
on delete cascade; -- Optional: delete conversations if the dialog is deleted.


--======================================================================================================================================================
------------------------------------------------------- Ragflow native development (Vector Store)-------------------------------------------------------
--======================================================================================================================================================

-- =====================================================================================
-- Translation of RAGFlow Relational Schema (Python ORM to SQL)
-- Based on Knowledgebase, Document, File, File2Document, Task, Dialog, and Conversation models.
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- TABLE: embedding_ragflow
-- Defines the vector store generated by ragflow
-- -------------------------------------------------------------------------------------

create table if not exists embeddings_ragflow(
  chunk_id varchar(32) primary key not null,
  chunk_text varchar(32) not null default 'NULL',
  db_ragflow_id  varchar(32) not null, 
  document_id varchar(32) not null,
  document_name varchar(64) not null,
  metadata jsonb not null, 
  embedding vector(768),
  llm_id varchar(32)
);

create index idx_chunk_id ON embeddings_ragflow (chunk_id);
create index idx_db_ragflow_id ON embeddings_ragflow (db_ragflow_id);
create index idx_document_id ON embeddings_ragflow (document_id);