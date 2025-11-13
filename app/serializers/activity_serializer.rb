class ActivitySerializer
  def initialize(activity)
    @activity = activity
  end

  def as_json(*args)
    {
      id: @activity.id,
      action: @activity.action,
      description: @activity.description,
      icon: @activity.icon,
      color: @activity.color,
      user: {
        id: @activity.user&.id,
        email: @activity.user&.email,
        name: @activity.user&.full_name
      },
      trackable_type: @activity.trackable_type,
      trackable_id: @activity.trackable_id,
      trackable_name: @activity.trackable_name,
      metadata: @activity.metadata,
      created_at: @activity.created_at&.iso8601,
      updated_at: @activity.updated_at&.iso8601
    }
  end
end
