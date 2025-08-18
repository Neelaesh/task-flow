import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'

export const POST: RequestHandler = async ({ locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		if (!session || !user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		// Create sample projects for the current user
		const projects = [
			{
				name: 'Website Redesign',
				description: 'Complete overhaul of company website',
				color: '#3B82F6'
			},
			{
				name: 'Mobile App Development', 
				description: 'iOS and Android app for customer portal',
				color: '#10B981'
			},
			{
				name: 'Database Migration',
				description: 'Migrate from PostgreSQL 12 to 15',
				color: '#F59E0B',
				status: 'completed'
			}
		]

		const createdProjects = []
		for (const project of projects) {
			const { data, error } = await locals.supabase
				.from('projects')
				.insert({
					name: project.name,
					description: project.description,
					owner_id: user.id,
					color: project.color,
					status: project.status || 'active'
				})
				.select()
				.single()

			if (error) throw error
			createdProjects.push(data)
		}

		return json({ message: 'Sample data created', projects: createdProjects })
	} catch (error) {
		console.error('Error seeding data:', error)
		return json({ error: 'Failed to seed data' }, { status: 500 })
	}
}
