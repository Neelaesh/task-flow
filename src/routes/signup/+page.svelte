<script lang="ts">
	import { supabase } from '$lib/supabase'
	import { goto } from '$app/navigation'

	let email = ''
	let password = ''
	let loading = false
	let error = ''
	let success = ''

	async function handleSignUp() {
		loading = true
		error = ''
		success = ''

		const { data, error: signUpError } = await supabase.auth.signUp({
			email,
			password
		})

		loading = false

		if (signUpError) {
			error = signUpError.message
		} else if (data.user) {
			goto('/')
		}
	}
</script>

<svelte:head>
	<title>Sign Up - TaskFlow</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-gray-50">
	<div class="max-w-md w-full space-y-8">
		<div>
			<h2 class="mt-6 text-center text-3xl font-bold text-gray-900">
				Create your account
			</h2>
		</div>
		<form class="mt-8 space-y-6" on:submit|preventDefault={handleSignUp}>
			<div class="space-y-4">
				<div>
					<label for="email" class="block text-sm font-medium text-gray-700">
						Email address
					</label>
					<input
						id="email"
						name="email"
						type="email"
						autocomplete="email"
						required
						bind:value={email}
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
					/>
				</div>
				<div>
					<label for="password" class="block text-sm font-medium text-gray-700">
						Password
					</label>
					<input
						id="password"
						name="password"
						type="password"
						autocomplete="new-password"
						required
						bind:value={password}
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
					/>
				</div>
			</div>

			{#if error}
				<div class="text-red-600 text-sm">
					{error}
				</div>
			{/if}

			{#if success}
				<div class="text-green-600 text-sm">
					{success}
				</div>
			{/if}

			<div>
				<button
					type="submit"
					disabled={loading}
					class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
				>
					{loading ? 'Signing up...' : 'Sign up'}
				</button>
			</div>

			<div class="text-center">
				<p class="text-sm text-gray-600">
					Already have an account? 
					<a href="/sign-in" class="font-medium text-blue-600 hover:text-blue-500">
						Sign in
					</a>
				</p>
			</div>
		</form>
	</div>
</div>
