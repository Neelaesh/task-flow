<script>
	import { onMount } from 'svelte'
	import { supabase } from '$lib/supabase'

	let session = null
	let accessToken = ''

	onMount(async () => {
		const { data } = await supabase.auth.getSession()
		session = data.session
		accessToken = data.session?.access_token || ''
	})
</script>

{#if session}
	<h2>Session Details</h2>
	<p><strong>User ID:</strong> {session.user.id}</p>
	<p><strong>Access Token:</strong></p>
	<textarea readonly style="width: 100%; height: 100px;">{accessToken}</textarea>
	
	<h3>Test Commands:</h3>
	<pre>
# Create project
curl -X POST http://localhost:5173/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {accessToken}" \
  -d '{{"name": "Test Project", "description": "Test"}}'

# Get projects  
curl -X GET http://localhost:5173/api/projects \
  -H "Authorization: Bearer {accessToken}"
	</pre>
{:else}
	<p>Please sign in first</p>
{/if}
