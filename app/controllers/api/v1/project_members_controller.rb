module Api
  module V1
    class ProjectMembersController < BaseController
      before_action :set_project
      before_action :set_member, only: [:show, :update, :destroy]
      before_action :authorize_project

      def index
        @members = @project.project_members.includes(:user)
        render json: @members.as_json(
          include: {
            user: { only: [:id, :email] }
          }
        )
      end

      def show
        render json: @member.as_json(include: { user: { only: [:id, :email] } })
      end

      def create
        @user = User.find(member_params[:user_id])
        @member = @project.project_members.build(
          user: @user,
          role: member_params[:role] || 'member'
        )

        if @member.save
          render json: @member.as_json(include: { user: { only: [:id, :email] } }), status: :created
        else
          render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @member.update(member_params)
          render json: @member.as_json(include: { user: { only: [:id, :email] } })
        else
          render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @member.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_member
        @member = @project.project_members.find(params[:id])
      end

      def authorize_project
        unless @project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def member_params
        params.require(:project_member).permit(:user_id, :role)
      end
    end
  end
end
