<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabase';

	export let user: any = null;

	let sidebarOpen = false;
	let mounted = false;

	onMount(() => {
		mounted = true;
	});

	const toggleSidebar = () => {
		sidebarOpen = !sidebarOpen;
	};

	const closeSidebar = () => {
		sidebarOpen = false;
	};

	const signOut = async () => {
		await supabase.auth.signOut();
	};

	// Navigation items
	const navigationItems = [
		{ name: 'Dashboard', href: '/', icon: 'home' },
		{ name: 'Projects', href: '/projects', icon: 'folder' },
		{ name: 'Tasks', href: '/tasks', icon: 'tasks' },
		{ name: 'Calendar', href: '/calendar', icon: 'calendar' },
		{ name: 'Team', href: '/team', icon: 'team' },
		{ name: 'Settings', href: '/settings', icon: 'settings' }
	];

	// Generate breadcrumbs from current route
	$: breadcrumbs = generateBreadcrumbs($page.url.pathname);

	function generateBreadcrumbs(pathname: string) {
		const segments = pathname.split('/').filter(Boolean);
		const breadcrumbs = [{ name: 'Home', href: '/' }];
		
		let currentPath = '';
		segments.forEach(segment => {
			currentPath += `/${segment}`;
			const name = segment.charAt(0).toUpperCase() + segment.slice(1);
			breadcrumbs.push({ name, href: currentPath });
		});
		
		return breadcrumbs;
	}

	function getIcon(iconName: string) {
		const icons: Record<string, string> = {
			home: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
			tasks: 'M9 5H7a2 2 0 00-2 2v6a2 2 0 002 2h2V9a2 2 0 012-2h2a2 2 0 012 2v6a2 2 0 002 2h2a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4 0V5a2 2 0 00-2-2H9a2 2 0 00-2 2v0',
			folder: 'M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z',
			calendar: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
			team: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
			settings: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z',
			menu: 'M4 6h16M4 12h16M4 18h16',
			close: 'M6 18L18 6M6 6l12 12',
			chevronRight: 'M9 5l7 7-7 7'
		};
		return icons[iconName] || icons.home;
	}
</script>

<!-- Mobile sidebar overlay -->
{#if mounted && sidebarOpen}
	<div 
		class="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
		role="button"
		tabindex="-1"
		on:click={closeSidebar}
		on:keydown={(e) => e.key === 'Escape' && closeSidebar()}
	></div>
{/if}

<div class="flex h-screen bg-gray-50">
	<!-- Sidebar -->
	<div class={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
		<!-- Sidebar header -->
		<div class="flex items-center justify-between p-4 border-b border-gray-200">
			<h2 class="text-xl font-semibold text-gray-800">TaskFlow</h2>
			<button 
				class="lg:hidden p-2 rounded-md text-gray-500 hover:text-gray-700 hover:bg-gray-100"
				on:click={closeSidebar}
				aria-label="Close sidebar"
			>
				<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getIcon('close')} />
				</svg>
			</button>
		</div>

		<!-- Navigation -->
		<nav class="mt-4 px-4">
			<ul class="space-y-2">
				{#each navigationItems as item}
					<li>
						<a 
							href={item.href}
							class={`flex items-center px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200 ${
								$page.url.pathname === item.href 
									? 'bg-blue-100 text-blue-700' 
									: 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'
							}`}
							on:click={closeSidebar}
						>
							<svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getIcon(item.icon)} />
							</svg>
							{item.name}
						</a>
					</li>
				{/each}
			</ul>
		</nav>

		<!-- User profile section -->
		{#if user}
			<div class="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 bg-white">
				<div class="flex items-center space-x-3">
					<div class="flex-shrink-0">
						<div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
							<span class="text-white font-medium text-sm">
								{user.email?.charAt(0).toUpperCase() || 'U'}
							</span>
						</div>
					</div>
					<div class="flex-1 min-w-0">
						<p class="text-sm font-medium text-gray-900 truncate">
							{user.email || 'User'}
						</p>
						<p class="text-xs text-gray-500">Online</p>
					</div>
					<button 
						class="flex-shrink-0 p-1 rounded-md text-gray-400 hover:text-gray-500"
						on:click={signOut}
						title="Sign out"
						aria-label="Sign out"
					>
						<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
						</svg>
					</button>
				</div>
			</div>
		{:else}
			<div class="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 bg-white">
				<a 
					href="/sign-in"
					class="w-full flex items-center justify-center px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
				>
					Sign In
				</a>
			</div>
		{/if}
	</div>

	<!-- Main content area -->
	<div class="flex-1 flex flex-col overflow-hidden">
		<!-- Top header -->
		<header class="bg-white shadow-sm border-b border-gray-200">
			<div class="flex items-center justify-between px-4 py-3">
				<!-- Mobile menu button -->
				<button 
					class="lg:hidden p-2 rounded-md text-gray-500 hover:text-gray-700 hover:bg-gray-100"
					on:click={toggleSidebar}
					aria-label="Open sidebar"
				>
					<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getIcon('menu')} />
					</svg>
				</button>

				<!-- Spacer for centering -->
				<div class="flex-1"></div>

				<!-- User avatar or Sign In button -->
				{#if user}
					<div class="hidden lg:flex items-center space-x-3">
						<div class="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center">
							<span class="text-white font-medium text-sm">
								{user.email?.charAt(0).toUpperCase() || 'U'}
							</span>
						</div>
						<span class="text-sm text-gray-700">{user.email}</span>
					</div>
				{:else}
					<a 
						href="/sign-in"
						class="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
					>
						Sign In
					</a>
				{/if}
			</div>
		</header>

		<!-- Main content -->
		<main class="flex-1 overflow-y-auto p-6">
			<slot />
		</main>
	</div>
</div>

<style>
	/* Ensure sidebar transitions work on mobile */
	@media (max-width: 1023px) {
		.translate-x-0 {
			transform: translateX(0);
		}
		.-translate-x-full {
			transform: translateX(-100%);
		}
	}
</style>
