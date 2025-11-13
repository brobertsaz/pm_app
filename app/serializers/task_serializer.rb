class TaskSerializer
  def initialize(task)
    @task = task
  end

  def as_json(*args)
    {
      id: @task.id,
      title: @task.title,
      description: @task.description,
      status: @task.status,
      priority: @task.priority,
      position: @task.position,
      due_date: @task.due_date&.iso8601,
      completed: @task.completed?,
      overdue: @task.overdue?,
      project_id: @task.project_id,
      project: {
        id: @task.project&.id,
        name: @task.project&.name
      },
      user: {
        id: @task.user&.id,
        email: @task.user&.email,
        name: @task.user&.full_name
      },
      time_logged: @task.total_time_logged,
      tag_count: @task.tags.count,
      comment_count: @task.comments.count,
      created_at: @task.created_at&.iso8601,
      updated_at: @task.updated_at&.iso8601
    }
  end
end
