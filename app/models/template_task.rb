class TemplateTask < ApplicationRecord
  belongs_to :project_template

  validates :title, presence: true
  validates :status, inclusion: { in: %w[To\ Do In\ Progress Done] }, allow_blank: true
  validates :priority, inclusion: { in: %w[Low Medium High] }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  def move_to_position(new_position)
    template_tasks = project_template.template_tasks.ordered
    current_index = template_tasks.pluck(:id).index(id)
    return if current_index.nil?

    if new_position > current_index
      template_tasks[current_index + 1..new_position].each_with_index do |task, idx|
        task.update(position: task.position - 1)
      end
    elsif new_position < current_index
      template_tasks[new_position..current_index - 1].each_with_index do |task, idx|
        task.update(position: task.position + 1)
      end
    end

    update(position: new_position)
  end
end
