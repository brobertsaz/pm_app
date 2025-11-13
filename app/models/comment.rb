class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }

  # Broadcast comment updates in real-time
  after_create :broadcast_comment_created
  after_update :broadcast_comment_updated
  before_destroy :broadcast_comment_deleted

  private

  def broadcast_comment_created
    project = get_project
    return unless project.present?

    CommentChannel.broadcast_comment_created(project, self)
  end

  def broadcast_comment_updated
    if saved_changes.present?
      project = get_project
      return unless project.present?

      CommentChannel.broadcast_comment_updated(project, self)
    end
  end

  def broadcast_comment_deleted
    project = get_project
    return unless project.present?

    CommentChannel.broadcast_comment_deleted(project, self)
  end

  def get_project
    case commentable_type
    when 'Project'
      commentable
    when 'Task'
      commentable&.project
    else
      nil
    end
  end
end
