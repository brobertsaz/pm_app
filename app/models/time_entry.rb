class TimeEntry < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :hours, presence: true, numericality: { greater_than: 0 }
  validates :logged_date, presence: true

  scope :for_task, ->(task) { where(task: task) }
  scope :for_date_range, ->(start_date, end_date) { where(logged_date: start_date..end_date) }

  def self.total_hours
    sum(:hours)
  end
end
