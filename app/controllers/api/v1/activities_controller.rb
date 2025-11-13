module Api
  module V1
    class ActivitiesController < BaseController
      before_action :set_project, only: [:index]

      def index
        @activities = if params[:project_id]
                        Activity.for_project(@project).recent
                      elsif params[:user_id]
                        Activity.for_user(current_user).recent
                      else
                        Activity.where(user: current_user).recent
                      end

        @activities = @activities.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          activities: @activities.as_json(
            include: {
              user: { only: [:id, :email] },
              project: { only: [:id, :name] }
            },
            methods: [:description, :icon, :color]
          ),
          pagination: {
            current_page: @activities.current_page,
            per_page: @activities.limit_value,
            total_pages: @activities.total_pages,
            total_entries: @activities.total_count
          }
        }
      end

      private

      def set_project
        @project = Project.find(params[:project_id]) if params[:project_id]
      end
    end
  end
end
