-- Complete sample data for TaskFlow database
-- Insert in correct order to respect foreign key constraints and RLS policies
-- Replace the UUIDs with actual auth.users IDs from your Supabase

-- Step 1: Insert profiles (must reference existing auth.users)
-- Note: You need to replace these UUIDs with actual user IDs from auth.users table
INSERT INTO profiles (id, email, full_name, timezone) VALUES 
    ('550e8400-e29b-41d4-a716-446655440000', 'john.doe@example.com', 'John Doe', 'UTC'),
    ('550e8400-e29b-41d4-a716-446655440001', 'jane.smith@example.com', 'Jane Smith', 'America/New_York'),
    ('550e8400-e29b-41d4-a716-446655440002', 'bob.wilson@example.com', 'Bob Wilson', 'Europe/London')
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    timezone = EXCLUDED.timezone,
    updated_at = NOW();

-- Step 2: Insert projects (references profiles)
INSERT INTO projects (id, name, description, owner_id, status, color) VALUES 
    ('660e8400-e29b-41d4-a716-446655440000', 'Website Redesign', 'Complete overhaul of company website', '550e8400-e29b-41d4-a716-446655440000', 'active', '#3B82F6'),
    ('660e8400-e29b-41d4-a716-446655440001', 'Mobile App Development', 'iOS and Android app for customer portal', '550e8400-e29b-41d4-a716-446655440001', 'active', '#10B981'),
    ('660e8400-e29b-41d4-a716-446655440002', 'Database Migration', 'Migrate from PostgreSQL 12 to 15', '550e8400-e29b-41d4-a716-446655440000', 'completed', '#F59E0B'),
    ('660e8400-e29b-41d4-a716-446655440003', 'API Documentation', 'Update all API endpoints documentation', '550e8400-e29b-41d4-a716-446655440002', 'archived', '#EF4444')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    color = EXCLUDED.color,
    updated_at = NOW();

-- Step 3: Insert project members (references projects and profiles)
INSERT INTO project_members (id, project_id, user_id, role) VALUES 
    ('bb0e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'admin'),
    ('bb0e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'member'),
    ('bb0e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'member'),
    ('bb0e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'viewer'),
    ('bb0e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'admin')
ON CONFLICT (project_id, user_id) DO UPDATE SET
    role = EXCLUDED.role;

-- Step 4: Insert tasks (references projects and profiles)
INSERT INTO tasks (id, title, description, project_id, assignee_id, creator_id, status, priority, due_date, estimated_hours, tags, position) VALUES 
    ('770e8400-e29b-41d4-a716-446655440000', 'Design homepage mockup', 'Create wireframes and mockups for new homepage', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'in_progress', 'high', '2024-02-01 17:00:00+00', 8, ARRAY['design', 'frontend'], 1),
    ('770e8400-e29b-41d4-a716-446655440001', 'Implement user authentication', 'Set up OAuth and session management', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'todo', 'urgent', '2024-01-28 12:00:00+00', 12, ARRAY['backend', 'security'], 2),
    ('770e8400-e29b-41d4-a716-446655440002', 'Create React Native components', 'Build reusable UI components for mobile app', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'review', 'medium', '2024-02-15 09:00:00+00', 16, ARRAY['mobile', 'react-native'], 1),
    ('770e8400-e29b-41d4-a716-446655440003', 'Setup CI/CD pipeline', 'Configure GitHub Actions for automated deployment', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'done', 'medium', NULL, 4, ARRAY['devops', 'ci-cd'], 2),
    ('770e8400-e29b-41d4-a716-446655440004', 'Database schema optimization', 'Optimize queries and add missing indexes', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'done', 'low', NULL, 6, ARRAY['database', 'performance'], 1),
    ('770e8400-e29b-41d4-a716-446655440005', 'Write API endpoints documentation', 'Document all REST API endpoints with examples', '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'cancelled', 'low', NULL, NULL, ARRAY['documentation'], 1)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    priority = EXCLUDED.priority,
    updated_at = NOW();

-- Step 5: Insert comments (references tasks and profiles)
INSERT INTO comments (id, task_id, author_id, content) VALUES 
    ('880e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'Started working on the wireframes. Should have initial drafts by tomorrow.'),
    ('880e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'Looks great! Please make sure to include mobile responsive designs.'),
    ('880e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Components are ready for review. Added comprehensive unit tests.'),
    ('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'CI/CD pipeline is now live and working perfectly!'),
    ('880e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Query performance improved by 300% after adding the new indexes.')
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    updated_at = NOW();

-- Step 6: Insert attachments (references tasks and profiles)
INSERT INTO attachments (id, task_id, uploader_id, filename, file_path, file_size, mime_type) VALUES 
    ('990e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'homepage_wireframe.pdf', '/uploads/homepage_wireframe.pdf', 2048576, 'application/pdf'),
    ('990e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'design_mockup.figma', '/uploads/design_mockup.figma', 5242880, 'application/octet-stream'),
    ('990e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'component_screenshots.zip', '/uploads/component_screenshots.zip', 10485760, 'application/zip'),
    ('990e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'deployment_config.yaml', '/uploads/deployment_config.yaml', 4096, 'text/yaml')
ON CONFLICT (id) DO UPDATE SET
    filename = EXCLUDED.filename,
    file_path = EXCLUDED.file_path,
    file_size = EXCLUDED.file_size,
    mime_type = EXCLUDED.mime_type;

-- Step 7: Insert activity (references profiles and projects)
-- Note: These would normally be created automatically by triggers
INSERT INTO activity (id, actor_id, action, entity_type, entity_id, project_id, metadata) VALUES 
    ('aa0e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'created', 'project', '660e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '{"new": {"name": "Website Redesign"}}'),
    ('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'created', 'project', '660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '{"new": {"name": "Mobile App Development"}}'),
    ('aa0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'created', 'task', '770e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '{"new": {"title": "Design homepage mockup"}}'),
    ('aa0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'updated', 'task', '770e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '{"old": {"status": "todo"}, "new": {"status": "in_progress"}}'),
    ('aa0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'completed', 'task', '770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', '{"old": {"status": "review"}, "new": {"status": "done"}}')
ON CONFLICT (id) DO UPDATE SET
    action = EXCLUDED.action,
    metadata = EXCLUDED.metadata;
