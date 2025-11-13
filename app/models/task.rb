class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true
  has_many :time_entries, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many_attached :files
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[To\ Do In\ Progress Done] }, allow_blank: true
  validates :priority, inclusion: { in: %w[Low Medium High] }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :for_project, ->(project) { where(project: project) }
  scope :search, ->(query) { search_by_query(query) if query.present? }
  scope :by_date_range, ->(start_date, end_date) {
    scope = all
    scope = scope.where('due_date >= ?', start_date) if start_date.present?
    scope = scope.where('due_date <= ?', end_date) if end_date.present?
    scope
  }

  def self.search_by_query(query)
    query_pattern = "%#{query}%"
    where(
      'title ILIKE :query OR description ILIKE :query',
      query: query_pattern
    )
  end

  after_create :track_creation, :broadcast_task_created, :send_task_created_email, :send_task_assigned_email
  after_update :track_update, :broadcast_task_updated, :send_task_status_notification_email
  before_destroy :broadcast_task_deleted

  def overdue?
    due_date.present? && due_date < Date.today && status != 'Done'
  end

  def completed?
    status == 'Done'
  end

  def total_time_logged
    time_entries.sum(:hours)
  end

  def track_activity(action, metadata = {})
    project.track_activity(action, metadata)
  end

  private

  def track_creation
    track_activity('created', { name: title })
  end

  def track_update
    track_activity('updated', { name: title })
  end

  def broadcast_task_created
    TaskChannel.broadcast_task_created(project, self)
  end

  def broadcast_task_updated
    # Check if status changed
    if status_changed?
      TaskChannel.broadcast_task_status_changed(project, self, status_was)
    elsif saved_changes.present? && id.present?
      TaskChannel.broadcast_task_updated(project, self)
    end
  end

  def broadcast_task_deleted
    TaskChannel.broadcast_task_deleted(project, self)
  end

  def send_task_created_email
    # Notify project team about the new task
    project.members.each do |member|
      TaskMailer.task_created(self, member).deliver_later
    end
  end

  def send_task_assigned_email
    # Notify the assigned user
    TaskMailer.task_assigned(self, user).deliver_later if user.present?
  end

  def send_task_status_notification_email
    # Check if status changed to 'Done' and notify team
    if status_changed? && status == 'Done'
      TaskMailer.task_completed(self).deliver_later
    end
  end
end
