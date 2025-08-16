<div class="max-w-7xl mx-auto">
	<div class="mb-8">
		<h1 class="text-3xl font-bold text-gray-900 mb-2">Welcome to TaskFlow</h1>
		<p class="text-gray-600">Manage your tasks and projects efficiently with our modern task management system.</p>
	</div>

	<!-- Dashboard grid -->
	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
		<!-- Stats cards -->
		<div class="bg-white rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-2 bg-blue-100 rounded-lg">
					<svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-600">Total Tasks</p>
					<p class="text-2xl font-semibold text-blue-600">12</p>
				</div>
			</div>
		</div>

		<div class="bg-white rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-2 bg-green-100 rounded-lg">
					<svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
					</svg>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-600">Completed</p>
					<p class="text-2xl font-semibold text-green-600">8</p>
				</div>
			</div>
		</div>

		<div class="bg-white rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-2 bg-yellow-100 rounded-lg">
					<svg class="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
					</svg>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-600">In Progress</p>
					<p class="text-2xl font-semibold text-yellow-600">3</p>
				</div>
			</div>
		</div>

		<div class="bg-white rounded-lg shadow p-6">
			<div class="flex items-center">
				<div class="p-2 bg-red-100 rounded-lg">
					<svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
					</svg>
				</div>
				<div class="ml-4">
					<p class="text-sm font-medium text-gray-600">Overdue</p>
					<p class="text-2xl font-semibold text-red-600">1</p>
				</div>
			</div>
		</div>
	</div>

	<!-- Recent Activity -->
	<div class="bg-white rounded-lg shadow">
		<div class="px-6 py-4 border-b border-gray-200">
			<h3 class="text-lg font-medium text-gray-900">Recent Activity</h3>
		</div>
		<div class="p-6">
			<div class="space-y-4">
				<div class="flex items-start space-x-3">
					<div class="flex-shrink-0">
						<div class="h-2 w-2 bg-blue-500 rounded-full mt-2"></div>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-gray-900">Created new task "Review quarterly reports"</p>
						<p class="text-xs text-gray-500">2 hours ago</p>
					</div>
				</div>
				
				<div class="flex items-start space-x-3">
					<div class="flex-shrink-0">
						<div class="h-2 w-2 bg-green-500 rounded-full mt-2"></div>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-gray-900">Completed task "Update documentation"</p>
						<p class="text-xs text-gray-500">4 hours ago</p>
					</div>
				</div>
				
				<div class="flex items-start space-x-3">
					<div class="flex-shrink-0">
						<div class="h-2 w-2 bg-yellow-500 rounded-full mt-2"></div>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-gray-900">Started working on "Redesign landing page"</p>
						<p class="text-xs text-gray-500">1 day ago</p>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
