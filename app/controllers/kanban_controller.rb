class KanbanController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:index]
  after_action :verify_authorized

  # GET /kanban or /projects/:project_id/kanban
  def index
    authorize Task

    if @project
      # Kanban view for a specific project
      @tasks = @project.tasks.includes(:user)
    else
      # Kanban view for all user's tasks
      @tasks = policy_scope(Task).includes(:project, :user)
    end

    # Group tasks by status
    @tasks_by_status = @tasks.group_by(&:status).transform_keys { |k| k || 'To Do' }
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end
end
