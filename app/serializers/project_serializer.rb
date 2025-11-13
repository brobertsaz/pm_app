class ProjectSerializer
  def initialize(project)
    @project = project
  end

  def as_json(*args)
    {
      id: @project.id,
      name: @project.name,
      description: @project.description,
      status: @project.status,
      priority: @project.priority,
      start_date: @project.start_date&.iso8601,
      due_date: @project.due_date&.iso8601,
      completion_percentage: @project.completion_percentage,
      overdue: @project.overdue?,
      user: {
        id: @project.user&.id,
        email: @project.user&.email,
        name: @project.user&.full_name
      },
      task_count: @project.tasks.count,
      completed_task_count: @project.tasks.where(status: 'Done').count,
      member_count: @project.members.count,
      created_at: @project.created_at&.iso8601,
      updated_at: @project.updated_at&.iso8601
    }
  end
end
