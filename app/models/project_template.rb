class ProjectTemplate < ApplicationRecord
  belongs_to :user
  has_many :template_tasks, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  scope :public_templates, -> { where(is_public: true) }
  scope :user_templates, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }

  def create_project(user, project_name = nil)
    project = user.projects.build(
      name: project_name || name,
      description: description,
      status: 'Not Started',
      priority: 'Medium'
    )

    if project.save
      # Copy template tasks to project
      template_tasks.order(:position).each do |template_task|
        project.tasks.create!(
          title: template_task.title,
          description: template_task.description,
          status: template_task.status,
          priority: template_task.priority,
          position: template_task.position
        )
      end
    end

    project
  end

  def duplicate_from_project(project)
    update(
      description: project.description,
      template_tasks: project.tasks.map { |task|
        TemplateTask.new(
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          position: task.position
        )
      }
    )
  end
end
