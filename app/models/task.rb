class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :status, inclusion: { in: %w[To\ Do In\ Progress Done] }, allow_blank: true
  validates :priority, inclusion: { in: %w[Low Medium High] }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :for_project, ->(project) { where(project: project) }

  def overdue?
    due_date.present? && due_date < Date.today && status != 'Done'
  end

  def completed?
    status == 'Done'
  end
end
