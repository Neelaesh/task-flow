import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'

export const POST: RequestHandler = async ({ locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		if (!session || !user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		// Insert all data for the current authenticated user
		const userId = user.id

		// 1. Ensure profile exists
		await locals.supabase
			.from('profiles')
			.upsert({
				id: userId,
				email: user.email!,
				full_name: user.user_metadata?.full_name || 'Test User'
			})

		// 2. Create projects
		const { data: projects, error: projectError } = await locals.supabase
			.from('projects')
			.insert([
				{ name: 'Website Redesign', description: 'Complete overhaul of company website', owner_id: userId, color: '#3B82F6' },
				{ name: 'Mobile App Development', description: 'iOS and Android app for customer portal', owner_id: userId, color: '#10B981' },
				{ name: 'Database Migration', description: 'Migrate from PostgreSQL 12 to 15', owner_id: userId, status: 'completed', color: '#F59E0B' }
			])
			.select()

		if (projectError) throw projectError

		// 3. Create tasks for projects
		if (projects && projects.length > 0) {
			const { error: taskError } = await locals.supabase
				.from('tasks')
				.insert([
					{
						title: 'Design homepage mockup',
						description: 'Create wireframes and mockups for new homepage',
						project_id: projects[0].id,
						creator_id: userId,
						status: 'in_progress',
						priority: 'high',
						tags: ['design', 'frontend']
					},
					{
						title: 'Implement user authentication',
						description: 'Set up OAuth and session management',
						project_id: projects[0].id,
						creator_id: userId,
						status: 'todo',
						priority: 'urgent',
						tags: ['backend', 'security']
					},
					{
						title: 'Create React Native components',
						description: 'Build reusable UI components for mobile app',
						project_id: projects[1].id,
						creator_id: userId,
						status: 'review',
						priority: 'medium',
						tags: ['mobile', 'react-native']
					}
				])

			if (taskError) throw taskError
		}

		return json({ message: 'Sample data created successfully', projects })
	} catch (error) {
		console.error('Error seeding data:', error)
		return json({ 
			error: 'Failed to seed data', 
			details: error instanceof Error ? error.message : 'Unknown error' 
		}, { status: 500 })
	}
}
