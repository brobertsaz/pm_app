module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: [:show, :update, :destroy]
      before_action :authorize_project, only: [:update, :destroy]

      def index
        @projects = current_user.projects.includes(:tasks).recent
        render json: @projects.as_json(
          include: {
            tasks: { only: [:id, :title, :status, :priority] }
          },
          methods: [:completion_percentage, :overdue?]
        )
      end

      def show
        render json: @project.as_json(
          include: {
            tasks: { only: [:id, :title, :description, :status, :priority, :due_date, :position] },
            user: { only: [:id, :email] }
          },
          methods: [:completion_percentage, :overdue?]
        )
      end

      def create
        @project = current_user.projects.build(project_params)

        if @project.save
          render json: @project, status: :created
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @project.update(project_params)
          render json: @project
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def authorize_project
        unless @project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def project_params
        params.require(:project).permit(:name, :description, :status, :priority, :due_date)
      end
    end
  end
end
