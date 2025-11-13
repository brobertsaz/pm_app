module Api
  module V1
    class TasksController < BaseController
      before_action :set_project, only: [:show, :create, :update, :destroy]
      before_action :set_task, only: [:show, :update, :destroy]
      before_action :authorize_project, only: [:create, :update, :destroy]

      def index
        if params[:project_id].present?
          # Get tasks for a specific project
          @tasks = @project.tasks.ordered
        else
          # Get all tasks for current user across all projects
          @tasks = policy_scope(Task).ordered
        end

        render json: @tasks.as_json(
          include: {
            user: { only: [:id, :email] },
            project: { only: [:id, :name] }
          },
          methods: [:overdue?, :completed?]
        )
      end

      def show
        render json: @task.as_json(
          include: {
            user: { only: [:id, :email] },
            project: { only: [:id, :name] }
          },
          methods: [:overdue?, :completed?]
        )
      end

      def create
        @task = @project.tasks.build(task_params)
        @task.user = current_user

        if @task.save
          render json: @task, status: :created
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_task
        @task = @project.tasks.find(params[:id])
      end

      def authorize_project
        unless @project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :priority, :due_date, :position)
      end
    end
  end
end
