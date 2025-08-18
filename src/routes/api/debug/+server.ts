import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'

export const GET: RequestHandler = async ({ locals, cookies }) => {
	try {
		console.log('Debug: Starting session check')
		console.log('Debug: Available cookies:', cookies.getAll())
		
		// Try getting session directly from Supabase
		const directSession = await locals.supabase.auth.getSession()
		console.log('Debug: Direct Supabase session:', {
			hasData: !!directSession.data,
			hasSession: !!directSession.data.session,
			hasUser: !!directSession.data.session?.user,
			error: directSession.error
		})
		
		const { session, user } = await locals.safeGetSession()
		
		console.log('Debug: SafeGetSession result:', { 
			hasSession: !!session, 
			hasUser: !!user,
			userId: user?.id 
		})

		return json({
			authenticated: !!session?.user,
			user_id: user?.id || null,
			session_exists: !!session,
			user_exists: !!user,
			direct_session_exists: !!directSession.data.session,
			cookies_count: cookies.getAll().length,
			cookies: cookies.getAll().map(c => c.name)
		})
	} catch (error) {
		console.error('Debug error:', error)
		return json({ 
			error: 'Debug failed', 
			message: error instanceof Error ? error.message : 'Unknown error' 
		}, { status: 500 })
	}
}
