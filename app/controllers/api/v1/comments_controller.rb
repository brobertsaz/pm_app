module Api
  module V1
    class CommentsController < BaseController
      before_action :set_commentable
      before_action :set_comment, only: [:destroy]
      before_action :authorize_comment, only: [:destroy]

      def index
        @comments = @commentable.comments.includes(:user).order(created_at: :asc)
        render json: @comments.as_json(
          include: {
            user: { only: [:id, :email] }
          }
        )
      end

      def create
        @comment = @commentable.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
          render json: @comment.as_json(
            include: {
              user: { only: [:id, :email] }
            }
          ), status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        head :no_content
      end

      private

      def set_commentable
        if params[:project_id]
          @commentable = Project.find(params[:project_id])
        elsif params[:task_id]
          @commentable = Task.find(params[:task_id])
        end
      end

      def set_comment
        @comment = @commentable.comments.find(params[:id])
      end

      def authorize_comment
        unless @comment.user_id == current_user.id || @comment.commentable.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def comment_params
        params.require(:comment).permit(:body)
      end
    end
  end
end
