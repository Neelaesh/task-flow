-- TaskFlow Database Schema
-- Designed for Supabase with Row Level Security

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived', 'completed')),
    color TEXT DEFAULT '#3B82F6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project members table (many-to-many relationship)
CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, user_id)
);

-- Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    assignee_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    creator_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
    priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    due_date TIMESTAMP WITH TIME ZONE,
    estimated_hours INTEGER,
    actual_hours INTEGER,
    tags TEXT[],
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comments table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attachments table
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    uploader_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity log table
CREATE TABLE activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL CHECK (entity_type IN ('project', 'task', 'comment', 'attachment')),
    entity_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX idx_tasks_creator_id ON tasks(creator_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_position ON tasks(project_id, position);
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_comments_author_id ON comments(author_id);
CREATE INDEX idx_attachments_task_id ON attachments(task_id);
CREATE INDEX idx_attachments_uploader_id ON attachments(uploader_id);
CREATE INDEX idx_activity_project_id ON activity(project_id);
CREATE INDEX idx_activity_actor_id ON activity(actor_id);
CREATE INDEX idx_activity_entity_type_id ON activity(entity_type, entity_id);
CREATE INDEX idx_activity_created_at ON activity(created_at);

-- Composite indexes for common queries
CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_assignee_status ON tasks(assignee_id, status) WHERE assignee_id IS NOT NULL;

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for projects
CREATE POLICY "Project members can view projects" ON projects
    FOR SELECT USING (
        owner_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = projects.id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Project owners can update projects" ON projects
    FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY "Project owners and admins can delete projects" ON projects
    FOR DELETE USING (
        owner_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = projects.id AND user_id = auth.uid() AND role IN ('admin')
        )
    );

CREATE POLICY "Authenticated users can create projects" ON projects
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- RLS Policies for project_members
CREATE POLICY "Project members can view membership" ON project_members
    FOR SELECT USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM project_members pm2
            WHERE pm2.project_id = project_members.project_id AND pm2.user_id = auth.uid()
        )
    );

CREATE POLICY "Project owners and admins can manage members" ON project_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM projects p
            WHERE p.id = project_id AND p.owner_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM project_members pm
            WHERE pm.project_id = project_members.project_id 
            AND pm.user_id = auth.uid() 
            AND pm.role IN ('admin')
        )
    );

-- RLS Policies for tasks
CREATE POLICY "Project members can view tasks" ON tasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = tasks.project_id AND user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM projects
            WHERE id = tasks.project_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Project members can create tasks" ON tasks
    FOR INSERT WITH CHECK (
        auth.uid() = creator_id AND
        (EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = tasks.project_id AND user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM projects
            WHERE id = tasks.project_id AND owner_id = auth.uid()
        ))
    );

CREATE POLICY "Project members can update tasks" ON tasks
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = tasks.project_id AND user_id = auth.uid() AND role IN ('owner', 'admin', 'member')
        ) OR
        EXISTS (
            SELECT 1 FROM projects
            WHERE id = tasks.project_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Project owners and admins can delete tasks" ON tasks
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = tasks.project_id AND user_id = auth.uid() AND role IN ('owner', 'admin')
        ) OR
        EXISTS (
            SELECT 1 FROM projects
            WHERE id = tasks.project_id AND owner_id = auth.uid()
        )
    );

-- RLS Policies for comments
CREATE POLICY "Project members can view comments" ON comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = comments.task_id AND pm.user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN projects p ON p.id = t.project_id
            WHERE t.id = comments.task_id AND p.owner_id = auth.uid()
        )
    );

CREATE POLICY "Project members can create comments" ON comments
    FOR INSERT WITH CHECK (
        auth.uid() = author_id AND
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = comments.task_id AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Comment authors can update own comments" ON comments
    FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "Comment authors and project admins can delete comments" ON comments
    FOR DELETE USING (
        author_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = comments.task_id AND pm.user_id = auth.uid() AND pm.role IN ('owner', 'admin')
        )
    );

-- RLS Policies for attachments
CREATE POLICY "Project members can view attachments" ON attachments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = attachments.task_id AND pm.user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN projects p ON p.id = t.project_id
            WHERE t.id = attachments.task_id AND p.owner_id = auth.uid()
        )
    );

CREATE POLICY "Project members can upload attachments" ON attachments
    FOR INSERT WITH CHECK (
        auth.uid() = uploader_id AND
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = attachments.task_id AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Uploaders and project admins can delete attachments" ON attachments
    FOR DELETE USING (
        uploader_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM tasks t
            JOIN project_members pm ON pm.project_id = t.project_id
            WHERE t.id = attachments.task_id AND pm.user_id = auth.uid() AND pm.role IN ('owner', 'admin')
        )
    );

-- RLS Policies for activity
CREATE POLICY "Project members can view activity" ON activity
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_members
            WHERE project_id = activity.project_id AND user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM projects
            WHERE id = activity.project_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "System can insert activity" ON activity
    FOR INSERT WITH CHECK (true);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to log activity
CREATE OR REPLACE FUNCTION log_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO activity (actor_id, action, entity_type, entity_id, project_id, metadata)
        VALUES (
            auth.uid(),
            'created',
            TG_TABLE_NAME::TEXT,
            NEW.id,
            CASE 
                WHEN TG_TABLE_NAME = 'projects' THEN NEW.id
                WHEN TG_TABLE_NAME = 'tasks' THEN NEW.project_id
                WHEN TG_TABLE_NAME = 'comments' THEN (SELECT project_id FROM tasks WHERE id = NEW.task_id)
                WHEN TG_TABLE_NAME = 'attachments' THEN (SELECT project_id FROM tasks WHERE id = NEW.task_id)
            END,
            jsonb_build_object('new', to_jsonb(NEW))
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO activity (actor_id, action, entity_type, entity_id, project_id, metadata)
        VALUES (
            auth.uid(),
            'updated',
            TG_TABLE_NAME::TEXT,
            NEW.id,
            CASE 
                WHEN TG_TABLE_NAME = 'projects' THEN NEW.id
                WHEN TG_TABLE_NAME = 'tasks' THEN NEW.project_id
                WHEN TG_TABLE_NAME = 'comments' THEN (SELECT project_id FROM tasks WHERE id = NEW.task_id)
                WHEN TG_TABLE_NAME = 'attachments' THEN (SELECT project_id FROM tasks WHERE id = NEW.task_id)
            END,
            jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW))
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO activity (actor_id, action, entity_type, entity_id, project_id, metadata)
        VALUES (
            auth.uid(),
            'deleted',
            TG_TABLE_NAME::TEXT,
            OLD.id,
            CASE 
                WHEN TG_TABLE_NAME = 'projects' THEN OLD.id
                WHEN TG_TABLE_NAME = 'tasks' THEN OLD.project_id
                WHEN TG_TABLE_NAME = 'comments' THEN (SELECT project_id FROM tasks WHERE id = OLD.task_id)
                WHEN TG_TABLE_NAME = 'attachments' THEN (SELECT project_id FROM tasks WHERE id = OLD.task_id)
            END,
            jsonb_build_object('old', to_jsonb(OLD))
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Activity triggers
CREATE TRIGGER projects_activity_trigger
    AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW EXECUTE FUNCTION log_activity();

CREATE TRIGGER tasks_activity_trigger
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW EXECUTE FUNCTION log_activity();

CREATE TRIGGER comments_activity_trigger
    AFTER INSERT OR UPDATE OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION log_activity();

CREATE TRIGGER attachments_activity_trigger
    AFTER INSERT OR UPDATE OR DELETE ON attachments
    FOR EACH ROW EXECUTE FUNCTION log_activity();

-- Additional performance indexes
CREATE INDEX idx_tasks_tags ON tasks USING GIN(tags);
CREATE INDEX idx_activity_metadata ON activity USING GIN(metadata);
CREATE INDEX idx_projects_created_at ON projects(created_at);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_tasks_updated_at ON tasks(updated_at);

-- Partial indexes for active data
CREATE INDEX idx_active_projects ON projects(owner_id, created_at) WHERE status = 'active';
CREATE INDEX idx_open_tasks ON tasks(project_id, created_at) WHERE status IN ('todo', 'in_progress', 'review');

-- Functions for common queries
CREATE OR REPLACE FUNCTION get_user_projects(user_uuid UUID)
RETURNS TABLE (
    project_id UUID,
    project_name TEXT,
    role TEXT,
    task_count BIGINT,
    open_task_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        COALESCE(pm.role, 'owner') as role,
        COUNT(t.id) as task_count,
        COUNT(t.id) FILTER (WHERE t.status IN ('todo', 'in_progress', 'review')) as open_task_count
    FROM projects p
    LEFT JOIN project_members pm ON pm.project_id = p.id AND pm.user_id = user_uuid
    LEFT JOIN tasks t ON t.project_id = p.id
    WHERE p.owner_id = user_uuid OR pm.user_id = user_uuid
    GROUP BY p.id, p.name, pm.role
    ORDER BY p.updated_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Sample data (optional - remove if not needed)
-- INSERT INTO profiles (id, email, full_name) VALUES 
--     ('00000000-0000-0000-0000-000000000001', 'admin@taskflow.com', 'Admin User');
