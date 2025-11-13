module Api
  module V1
    class TagsController < BaseController
      before_action :set_project, except: [:index]
      before_action :set_tag, only: [:show, :update, :destroy]
      before_action :authorize_project, except: [:index]

      def index
        # If project_id is present, get tags for that project
        # Otherwise, get all tags across all projects
        if params[:project_id].present?
          @tags = @project.tags
        else
          # Get all unique tags across all projects for the current user's projects
          @tags = Tag.joins(:project)
            .where(projects: { user_id: current_user.id })
            .distinct
            .order(:name)
        end
        render json: @tags
      end

      def show
        render json: @tag.as_json(include: { taggings: { only: [:id, :taggable_type, :taggable_id] } })
      end

      def create
        @tag = @project.tags.build(tag_params)

        if @tag.save
          render json: @tag, status: :created
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @tag.update(tag_params)
          render json: @tag
        else
          render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @tag.destroy
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_tag
        @tag = @project.tags.find(params[:id])
      end

      def authorize_project
        unless @project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def tag_params
        params.require(:tag).permit(:name, :color)
      end
    end
  end
end
