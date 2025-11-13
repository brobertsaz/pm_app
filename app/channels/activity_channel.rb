class ActivityChannel < ApplicationCable::Channel
  def subscribed
    project_id = params['project_id']

    if project_id.present?
      @project = Project.find_by(id: project_id)

      if @project.present?
        stream_for @project
        transmit(
          type: 'subscription_confirmed',
          message: "Connected to project activity stream",
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

  def request_recent_activities
    # Allow clients to request recent activities
    if @project.present?
      activities = @project.activities.recent.limit(20).map do |activity|
        ActivitySerializer.new(activity).as_json
      end

      transmit(
        type: 'recent_activities',
        activities: activities,
        timestamp: Time.current.iso8601
      )
    end
  end

  # Called from BroadcastActivityJob
  def self.broadcast_activity(project, activity)
    broadcast_to project, {
      type: 'activity_created',
      activity: ActivitySerializer.new(activity).as_json,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end

  # Batch broadcast for multiple activities
  def self.broadcast_activities(project, activities)
    broadcast_to project, {
      type: 'activities_created',
      activities: activities.map { |a| ActivitySerializer.new(a).as_json },
      project_id: project.id,
      count: activities.count,
      timestamp: Time.current.iso8601
    }
  end
end
