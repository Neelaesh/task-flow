<script lang="ts">
	import { invalidate } from '$app/navigation'
	import { onMount } from 'svelte'
	import { supabase } from '$lib/supabase'
	import Layout from '$lib/components/Layout.svelte'
	import '../app.css'

	export let data

	onMount(() => {
		const { data: authListener } = supabase.auth.onAuthStateChange((_, _session) => {
			invalidate('supabase:auth')
		})

		return () => authListener?.subscription.unsubscribe()
	})
</script>

<Layout user={data.user}>
	<slot />
</Layout>
