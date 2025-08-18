<script lang="ts">
	import { onMount } from 'svelte'
	import { projectsStore } from '$lib/stores/projects'

	onMount(async () => {
		// Debug authentication first
		try {
			const debugResponse = await fetch('/api/debug')
			const debugData = await debugResponse.json()
			console.log('Debug data:', debugData)
		} catch (error) {
			console.error('Debug failed:', error)
		}
		
		projectsStore.loadProjects()
	})

	async function createProject() {
		try {
			await projectsStore.createProject({
				name: 'New Project',
				description: 'Project created from UI'
			})
		} catch (error) {
			console.error('Failed to create project:', error)
		}
	}
</script>

<svelte:head>
	<title>Projects - TaskFlow</title>
</svelte:head>

<div class="p-6">
	<div class="flex justify-between items-center mb-6">
		<h1 class="text-2xl font-bold text-gray-900">Projects</h1>
		<button
			on:click={createProject}
			class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md font-medium"
		>
			New Project
		</button>
	</div>

	{#if $projectsStore.loading}
		<div class="flex justify-center items-center h-32">
			<div class="text-gray-500">Loading projects...</div>
		</div>
	{:else if $projectsStore.error}
		<div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
			{$projectsStore.error}
		</div>
	{:else if $projectsStore.projects.length === 0}
		<div class="text-center py-12">
			<div class="text-gray-500 mb-4">No projects yet</div>
			<button
				on:click={createProject}
				class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md font-medium"
			>
				Create your first project
			</button>
		</div>
	{:else}
		<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
			{#each $projectsStore.projects as project (project.id)}
				<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
					<div class="flex items-start justify-between mb-3">
						<div class="flex items-center">
							<div 
								class="w-4 h-4 rounded-full mr-3"
								style="background-color: {project.color}"
							></div>
							<h3 class="text-lg font-semibold text-gray-900">{project.name}</h3>
						</div>
						<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
							{project.status}
						</span>
					</div>
					
					{#if project.description}
						<p class="text-gray-600 text-sm mb-4">{project.description}</p>
					{/if}
					
					<div class="flex justify-between items-center text-xs text-gray-500">
						<span>Created {new Date(project.created_at).toLocaleDateString()}</span>
						<div class="flex space-x-2">
							<button 
								class="text-blue-600 hover:text-blue-800"
								on:click={() => projectsStore.updateProject(project.id, { status: 'completed' })}
							>
								Complete
							</button>
							<button 
								class="text-red-600 hover:text-red-800"
								on:click={() => projectsStore.deleteProject(project.id)}
							>
								Delete
							</button>
						</div>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
