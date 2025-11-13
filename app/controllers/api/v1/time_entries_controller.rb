module Api
  module V1
    class TimeEntriesController < BaseController
      before_action :set_task
      before_action :set_time_entry, only: [:show, :update, :destroy]
      before_action :authorize_task

      def index
        @time_entries = @task.time_entries.order(logged_date: :desc)
        render json: @time_entries.as_json(include: { user: { only: [:id, :email] } })
      end

      def show
        render json: @time_entry.as_json(include: { user: { only: [:id, :email] } })
      end

      def create
        @time_entry = @task.time_entries.build(time_entry_params)
        @time_entry.user = current_user

        if @time_entry.save
          render json: @time_entry.as_json(include: { user: { only: [:id, :email] } }), status: :created
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @time_entry.update(time_entry_params)
          render json: @time_entry.as_json(include: { user: { only: [:id, :email] } })
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @time_entry.destroy
        head :no_content
      end

      def summary
        @task = Task.find(params[:task_id])
        authorize_task

        start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
        end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

        entries = @task.time_entries.for_date_range(start_date, end_date)

        render json: {
          task_id: @task.id,
          task_title: @task.title,
          start_date: start_date,
          end_date: end_date,
          total_hours: entries.total_hours,
          entry_count: entries.count,
          entries_by_date: entries.group_by(&:logged_date).transform_values { |e| e.sum(&:hours) }
        }
      end

      private

      def set_task
        @task = Task.find(params[:task_id])
      end

      def set_time_entry
        @time_entry = @task.time_entries.find(params[:id])
      end

      def authorize_task
        project = @task.project
        unless project.user_id == current_user.id || project.members.include?(current_user)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def time_entry_params
        params.require(:time_entry).permit(:hours, :logged_date, :description)
      end
    end
  end
end
