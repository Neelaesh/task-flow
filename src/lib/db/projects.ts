import type { SupabaseClient } from '@supabase/supabase-js'

export interface Project {
	id: string
	name: string
	description: string | null
	owner_id: string
	status: 'active' | 'archived' | 'completed'
	color: string
	created_at: string
	updated_at: string
}

export interface CreateProjectData {
	name: string
	description?: string
	color?: string
}

export interface UpdateProjectData {
	name?: string
	description?: string
	status?: 'active' | 'archived' | 'completed'
	color?: string
}

export class ProjectService {
	constructor(private supabase: SupabaseClient) {}

	async getUserProjects(userId: string): Promise<Project[]> {
		// Simple query to avoid RLS policy recursion
		const { data, error } = await this.supabase
			.from('projects')
			.select('id, name, description, owner_id, status, color, created_at, updated_at')
			.eq('owner_id', userId)
			.order('updated_at', { ascending: false })

		if (error) throw error
		return data || []
	}

	async createProject(userId: string, projectData: CreateProjectData): Promise<Project> {
		const { data, error } = await this.supabase
			.from('projects')
			.insert({
				name: projectData.name,
				description: projectData.description || null,
				owner_id: userId,
				color: projectData.color || '#3B82F6'
			})
			.select()
			.single()

		if (error) throw error
		return data
	}

	async updateProject(projectId: string, updates: UpdateProjectData): Promise<Project> {
		const { data, error } = await this.supabase
			.from('projects')
			.update(updates)
			.eq('id', projectId)
			.select()
			.single()

		if (error) throw error
		return data
	}

	async deleteProject(projectId: string): Promise<void> {
		const { error } = await this.supabase
			.from('projects')
			.delete()
			.eq('id', projectId)

		if (error) throw error
	}

	async getProject(projectId: string): Promise<Project | null> {
		const { data, error } = await this.supabase
			.from('projects')
			.select('*')
			.eq('id', projectId)
			.single()

		if (error) {
			if (error.code === 'PGRST116') return null // Not found
			throw error
		}
		return data
	}
}
