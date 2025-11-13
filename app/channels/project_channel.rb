class ProjectChannel < ApplicationCable::Channel
  def subscribed
    project_id = params['project_id']

    if project_id.present?
      @project = Project.find_by(id: project_id)

      if @project.present?
        stream_for @project
        transmit(
          type: 'subscription_confirmed',
          message: "Connected to project #{@project.name}",
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

  def request_update
    # Allow clients to request a full project update
    if @project.present?
      broadcast_to @project, {
        type: 'project_update',
        project: ProjectSerializer.new(@project).as_json,
        timestamp: Time.current.iso8601
      }
    end
  end

  # Called from callbacks when a project is updated
  def self.broadcast_project_updated(project)
    broadcast_to project, {
      type: 'project_updated',
      action: 'updated',
      project: ProjectSerializer.new(project).as_json,
      timestamp: Time.current.iso8601
    }
  end

  # Called from callbacks when a project is created
  def self.broadcast_project_created(project)
    broadcast_to project, {
      type: 'project_created',
      action: 'created',
      project: ProjectSerializer.new(project).as_json,
      timestamp: Time.current.iso8601
    }
  end

  # Called from callbacks when a project is deleted
  def self.broadcast_project_deleted(project)
    broadcast_to project, {
      type: 'project_deleted',
      action: 'deleted',
      project_id: project.id,
      project_name: project.name,
      timestamp: Time.current.iso8601
    }
  end
end
