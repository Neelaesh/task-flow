import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'
import { ProjectService, type UpdateProjectData } from '$lib/db/projects'

export const GET: RequestHandler = async ({ params, locals }) => {
	try {
		const { session } = await locals.safeGetSession()
		if (!session?.user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		const projectService = new ProjectService(locals.supabase)
		const project = await projectService.getProject(params.id)

		if (!project) {
			return json({ error: 'Project not found' }, { status: 404 })
		}

		return json({ project })
	} catch (error) {
		console.error('Error fetching project:', error)
		return json({ error: 'Failed to fetch project' }, { status: 500 })
	}
}

export const PUT: RequestHandler = async ({ params, request, locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		if (!session || !user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		const body = await request.json()
		
		// Validation
		if (body.name !== undefined) {
			if (typeof body.name !== 'string' || body.name.trim().length === 0) {
				return json({ error: 'Project name cannot be empty' }, { status: 400 })
			}
			if (body.name.trim().length > 100) {
				return json({ error: 'Project name must be 100 characters or less' }, { status: 400 })
			}
		}

		if (body.description !== undefined && body.description !== null) {
			if (typeof body.description !== 'string' || body.description.length > 500) {
				return json({ error: 'Description must be 500 characters or less' }, { status: 400 })
			}
		}

		if (body.status !== undefined) {
			if (!['active', 'archived', 'completed'].includes(body.status)) {
				return json({ error: 'Invalid status' }, { status: 400 })
			}
		}

		if (body.color !== undefined && body.color !== null) {
			if (typeof body.color !== 'string' || !/^#[0-9A-Fa-f]{6}$/.test(body.color)) {
				return json({ error: 'Color must be a valid hex color' }, { status: 400 })
			}
		}

		const projectService = new ProjectService(locals.supabase)
		const updates: UpdateProjectData = {}
		
		if (body.name !== undefined) updates.name = body.name.trim()
		if (body.description !== undefined) updates.description = body.description?.trim() || null
		if (body.status !== undefined) updates.status = body.status
		if (body.color !== undefined) updates.color = body.color

		const project = await projectService.updateProject(params.id, updates)
		return json({ project })
	} catch (error) {
		console.error('Error updating project:', error)
		return json({ error: 'Failed to update project' }, { status: 500 })
	}
}

export const DELETE: RequestHandler = async ({ params, locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		if (!session || !user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		const projectService = new ProjectService(locals.supabase)
		await projectService.deleteProject(params.id)

		return json({ success: true })
	} catch (error) {
		console.error('Error deleting project:', error)
		return json({ error: 'Failed to delete project' }, { status: 500 })
	}
}
