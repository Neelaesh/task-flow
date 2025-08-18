import { writable } from 'svelte/store'
import type { Project, CreateProjectData, UpdateProjectData } from '$lib/db/projects'

interface ProjectsState {
	projects: Project[]
	loading: boolean
	error: string | null
}

const initialState: ProjectsState = {
	projects: [],
	loading: false,
	error: null
}

function createProjectsStore() {
	const { subscribe, set, update } = writable<ProjectsState>(initialState)

	return {
		subscribe,
		
		async loadProjects() {
			update(state => ({ ...state, loading: true, error: null }))
			
			try {
				const response = await fetch('/api/projects')
				if (!response.ok) {
					const { error } = await response.json()
					throw new Error(error || 'Failed to load projects')
				}
				
				const { projects } = await response.json()
				update(state => ({ ...state, projects, loading: false }))
			} catch (error) {
				update(state => ({ 
					...state, 
					loading: false, 
					error: error instanceof Error ? error.message : 'Failed to load projects' 
				}))
			}
		},

		async createProject(projectData: CreateProjectData): Promise<Project> {
			try {
				const response = await fetch('/api/projects', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify(projectData)
				})

				if (!response.ok) {
					const { error } = await response.json()
					throw new Error(error || 'Failed to create project')
				}

				const { project } = await response.json()
				
				// Optimistic update
				update(state => ({
					...state,
					projects: [project, ...state.projects],
					error: null
				}))

				return project
			} catch (error) {
				update(state => ({ 
					...state, 
					error: error instanceof Error ? error.message : 'Failed to create project' 
				}))
				throw error
			}
		},

		async updateProject(projectId: string, updates: UpdateProjectData): Promise<Project> {
			// Optimistic update
			update(state => ({
				...state,
				projects: state.projects.map(p => 
					p.id === projectId ? { ...p, ...updates } : p
				),
				error: null
			}))

			try {
				const response = await fetch(`/api/projects/${projectId}`, {
					method: 'PUT',
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify(updates)
				})

				if (!response.ok) {
					const { error } = await response.json()
					throw new Error(error || 'Failed to update project')
				}

				const { project } = await response.json()
				
				// Update with server response
				update(state => ({
					...state,
					projects: state.projects.map(p => 
						p.id === projectId ? project : p
					)
				}))

				return project
			} catch (error) {
				// Revert optimistic update
				this.loadProjects()
				update(state => ({ 
					...state, 
					error: error instanceof Error ? error.message : 'Failed to update project' 
				}))
				throw error
			}
		},

		async deleteProject(projectId: string): Promise<void> {
			// Optimistic update
			update(state => ({
				...state,
				projects: state.projects.filter(p => p.id !== projectId),
				error: null
			}))

			try {
				const response = await fetch(`/api/projects/${projectId}`, {
					method: 'DELETE'
				})

				if (!response.ok) {
					const { error } = await response.json()
					throw new Error(error || 'Failed to delete project')
				}
			} catch (error) {
				// Revert optimistic update
				this.loadProjects()
				update(state => ({ 
					...state, 
					error: error instanceof Error ? error.message : 'Failed to delete project' 
				}))
				throw error
			}
		},

		clearError() {
			update(state => ({ ...state, error: null }))
		},

		reset() {
			set(initialState)
		}
	}
}

export const projectsStore = createProjectsStore()
