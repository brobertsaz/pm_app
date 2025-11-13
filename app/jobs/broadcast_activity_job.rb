class BroadcastActivityJob < ApplicationJob
  queue_as :default

  # Broadcast activity creation to all project subscribers
  def perform(activity_id)
    activity = Activity.find_by(id: activity_id)
    return unless activity.present?

    project = activity.project
    return unless project.present?

    # Broadcast via ActivityChannel
    ActivityChannel.broadcast_activity(project, activity)

    # If the activity is related to a task, also broadcast via TaskChannel
    if activity.trackable_type == 'Task' && activity.trackable.present?
      TaskChannel.broadcast_task_updated(project, activity.trackable)
    end
  end
end
