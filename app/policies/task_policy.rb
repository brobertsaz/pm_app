class TaskPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:project).where(projects: { user_id: user.id })
    end
  end

  def index?
    project_owner?
  end

  def show?
    project_owner?
  end

  def create?
    project_owner?
  end

  def update?
    project_owner?
  end

  def destroy?
    project_owner?
  end

  private

  def project_owner?
    record.project.user_id == user.id
  end
end
