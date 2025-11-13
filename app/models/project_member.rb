class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :role, inclusion: { in: %w[owner admin member viewer] }
  validates :user_id, uniqueness: { scope: :project_id }

  after_create :send_project_assignment_email

  private

  def send_project_assignment_email
    ProjectMailer.project_assigned(project, user).deliver_later
  end
end
