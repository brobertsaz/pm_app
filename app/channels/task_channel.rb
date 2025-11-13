class TaskChannel < ApplicationCable::Channel
  def subscribed
    project_id = params['project_id']

    if project_id.present?
      @project = Project.find_by(id: project_id)

      if @project.present?
        stream_for @project
        transmit(
          type: 'subscription_confirmed',
          message: "Connected to project tasks stream",
          project_id: @project.id,
          timestamp: Time.current.iso8601
        )
      else
        reject
      end
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def request_tasks
    # Allow clients to request all project tasks
    if @project.present?
      tasks = @project.tasks.map do |task|
        TaskSerializer.new(task).as_json
      end

      transmit(
        type: 'tasks_list',
        tasks: tasks,
        count: tasks.count,
        timestamp: Time.current.iso8601
      )
    end
  end

  # Called from callbacks when a task is created
  def self.broadcast_task_created(project, task)
    broadcast_to project, {
      type: 'task_created',
      action: 'created',
      task: TaskSerializer.new(task).as_json,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end

  # Called from callbacks when a task is updated
  def self.broadcast_task_updated(project, task)
    broadcast_to project, {
      type: 'task_updated',
      action: 'updated',
      task: TaskSerializer.new(task).as_json,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end

  # Called from callbacks when a task is deleted
  def self.broadcast_task_deleted(project, task)
    broadcast_to project, {
      type: 'task_deleted',
      action: 'deleted',
      task_id: task.id,
      task_title: task.title,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end

  # Called when task status is changed
  def self.broadcast_task_status_changed(project, task, old_status)
    broadcast_to project, {
      type: 'task_status_changed',
      task: TaskSerializer.new(task).as_json,
      old_status: old_status,
      new_status: task.status,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end
end
