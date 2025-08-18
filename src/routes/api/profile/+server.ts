import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'

export const POST: RequestHandler = async ({ locals }) => {
	try {
		const { session, user } = await locals.safeGetSession()
		if (!session || !user) {
			return json({ error: 'Unauthorized' }, { status: 401 })
		}

		// Create profile for the user
		const { data: profile, error } = await locals.supabase
			.from('profiles')
			.upsert({
				id: user.id,
				email: user.email!,
				full_name: user.user_metadata?.full_name || null,
				avatar_url: user.user_metadata?.avatar_url || null
			})
			.select()
			.single()

		if (error) {
			console.error('Error creating profile:', error)
			return json({ error: 'Failed to create profile' }, { status: 500 })
		}

		return json({ profile })
	} catch (error) {
		console.error('Error in profile endpoint:', error)
		return json({ error: 'Failed to process request' }, { status: 500 })
	}
}
