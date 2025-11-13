class Project < ApplicationRecord
  belongs_to :user, optional: true
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: %w[Not\ Started In\ Progress Completed On\ Hold] }, allow_blank: true
  validates :priority, inclusion: { in: %w[Low Medium High] }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def completion_percentage
    return 0 if tasks.count.zero?
    (tasks.where(status: 'Done').count.to_f / tasks.count * 100).round(2)
  end

  def overdue?
    due_date.present? && due_date < Date.today && status != 'Completed'
  end
end
