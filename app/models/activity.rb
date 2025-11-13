class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  belongs_to :project, optional: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_project, ->(project) { where(project: project) }
  scope :for_user, ->(user) { where(user: user) }

  # Broadcast activity creation in real-time
  after_create :broadcast_activity_created

  private

  def broadcast_activity_created
    return unless project.present?

    # Queue the broadcast job for async processing
    BroadcastActivityJob.perform_later(id)
  end

  def description
    case action
    when 'created'
      "#{user.full_name} created #{trackable_type.downcase} \"#{trackable_name}\""
    when 'updated'
      "#{user.full_name} updated #{trackable_type.downcase} \"#{trackable_name}\""
    when 'deleted'
      "#{user.full_name} deleted #{trackable_type.downcase} \"#{trackable_name}\""
    when 'completed'
      "#{user.full_name} completed #{trackable_type.downcase} \"#{trackable_name}\""
    when 'commented'
      "#{user.full_name} commented on #{trackable_type.downcase} \"#{trackable_name}\""
    else
      "#{user.full_name} #{action} #{trackable_type.downcase}"
    end
  end

  def trackable_name
    metadata['name'] || trackable&.name || trackable&.title || 'Unknown'
  end

  def icon
    case action
    when 'created' then 'mdi-plus-circle'
    when 'updated' then 'mdi-pencil'
    when 'deleted' then 'mdi-delete'
    when 'completed' then 'mdi-check-circle'
    when 'commented' then 'mdi-comment'
    else 'mdi-information'
    end
  end

  def color
    case action
    when 'created' then 'success'
    when 'updated' then 'info'
    when 'deleted' then 'error'
    when 'completed' then 'success'
    when 'commented' then 'primary'
    else 'secondary'
    end
  end
end
