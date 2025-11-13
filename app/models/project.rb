class Project < ApplicationRecord
  belongs_to :user, optional: true
  has_many :tasks, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user
  has_many :tags, dependent: :destroy
  has_many_attached :files
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: %w[Not\ Started In\ Progress Completed On\ Hold] }, allow_blank: true
  validates :priority, inclusion: { in: %w[Low Medium High] }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :search, ->(query) { search_by_query(query) if query.present? }
  scope :by_date_range, ->(start_date, end_date) {
    scope = all
    scope = scope.where('created_at >= ?', start_date) if start_date.present?
    scope = scope.where('created_at <= ?', end_date) if end_date.present?
    scope
  }

  def self.search_by_query(query)
    query_pattern = "%#{query}%"
    where(
      'name ILIKE :query OR description ILIKE :query',
      query: query_pattern
    )
  end

  after_create :track_creation, :broadcast_project_created, :send_project_created_email
  after_update :track_update, :broadcast_project_updated, :send_project_updated_email
  before_destroy :broadcast_project_deleted

  def completion_percentage
    return 0 if tasks.count.zero?
    (tasks.where(status: 'Done').count.to_f / tasks.count * 100).round(2)
  end

  def overdue?
    due_date.present? && due_date < Date.today && status != 'Completed'
  end

  def track_activity(action, metadata = {})
    activities.create!(
      action: action,
      user: user,
      metadata: metadata
    )
  end

  private

  def track_creation
    track_activity('created', { name: name })
  end

  def track_update
    track_activity('updated', { name: name })
  end

  def broadcast_project_created
    ProjectChannel.broadcast_project_created(self)
  end

  def broadcast_project_updated
    # Only broadcast if this is not the first update (i.e., after creation)
    if saved_changes.present? && id.present?
      ProjectChannel.broadcast_project_updated(self)
    end
  end

  def broadcast_project_deleted
    ProjectChannel.broadcast_project_deleted(self)
  end

  def send_project_created_email
    ProjectMailer.project_created(self, user).deliver_later if user.present?
  end

  def send_project_updated_email
    # Send notification to project creator/owner
    ProjectMailer.project_updated(self, user).deliver_later if user.present?
  end
end
