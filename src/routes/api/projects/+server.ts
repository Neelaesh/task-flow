import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'
import { ProjectService } from '$lib/db/projects'

export const GET: RequestHandler = async ({ locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		
		console.log('GET /api/projects - Session check:', { 
			hasSession: !!session, 
			hasUser: !!user,
			userId: user?.id 
		})
		
		if (!session || !user) {
			console.log('GET /api/projects - No valid session')
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		const projectService = new ProjectService(locals.supabase)
		const projects = await projectService.getUserProjects(user.id)

		return json({ projects })
	} catch (error) {
		console.error('Error fetching projects:', error)
		return json({ error: 'Failed to fetch projects' }, { status: 500 })
	}
}

export const POST: RequestHandler = async ({ request, locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		
		console.log('POST /api/projects - Session check:', { 
			hasSession: !!session, 
			hasUser: !!user,
			userId: user?.id 
		})
		
		if (!session || !user) {
			console.log('POST /api/projects - No valid session')
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		const body = await request.json()
		
		// Validation
		if (!body.name || typeof body.name !== 'string' || body.name.trim().length === 0) {
			return json({ error: 'Project name is required' }, { status: 400 })
		}

		if (body.name.trim().length > 100) {
			return json({ error: 'Project name must be 100 characters or less' }, { status: 400 })
		}

		if (body.description && typeof body.description === 'string' && body.description.length > 500) {
			return json({ error: 'Description must be 500 characters or less' }, { status: 400 })
		}

		if (body.color && typeof body.color === 'string' && !/^#[0-9A-Fa-f]{6}$/.test(body.color)) {
			return json({ error: 'Color must be a valid hex color' }, { status: 400 })
		}

		// Use the authenticated locals.supabase client which has proper RLS context
		const projectService = new ProjectService(locals.supabase)
		const project = await projectService.createProject(user.id, {
			name: body.name.trim(),
			description: body.description?.trim() || undefined,
			color: body.color || undefined
		})

		return json({ project }, { status: 201 })
	} catch (error) {
		console.error('Error creating project:', error)
		return json({ error: 'Failed to create project' }, { status: 500 })
	}
}
