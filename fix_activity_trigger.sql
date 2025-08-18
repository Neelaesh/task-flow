-- Fix for the log_activity function to handle project_members table
-- Run this to fix the trigger error

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
                WHEN TG_TABLE_NAME = 'project_members' THEN NEW.project_id
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
                WHEN TG_TABLE_NAME = 'project_members' THEN NEW.project_id
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
                WHEN TG_TABLE_NAME = 'project_members' THEN OLD.project_id
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
