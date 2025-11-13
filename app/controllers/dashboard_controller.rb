class DashboardController < ApplicationController
  def index
    @dashboard_data = build_dashboard_data

    respond_to do |format|
      format.html { render :index }
      format.json { render json: { dashboard_data: @dashboard_data } }
    end
  end

  private

  def build_dashboard_data
    {
      total_projects: current_user.projects.count,
      active_projects: current_user.projects.where(status: 'In Progress').count,
      completed_projects: current_user.projects.where(status: 'Completed').count,
      total_tasks: current_user.projects.joins(:tasks).count('tasks.id'),
      completed_tasks: Task.joins(:project).where(projects: { user_id: current_user.id }, status: 'Done').count,
      overdue_tasks: overdue_tasks_count,
      recent_activities: recent_activities,
      projects_by_status: projects_by_status,
      tasks_by_priority: tasks_by_priority,
      time_logged_this_week: calculate_time_logged_this_week
    }
  end

  def overdue_tasks_count
    Task.joins(:project)
        .where(projects: { user_id: current_user.id })
        .where('due_date < ?', Date.today)
        .where.not(status: 'Done')
        .count
  end

  def recent_activities
    Activity.joins(:project)
            .where(projects: { user_id: current_user.id })
            .recent
            .limit(10)
            .map do |activity|
              {
                id: activity.id,
                description: activity.description,
                action: activity.action,
                icon: activity.icon,
                color: activity.color,
                trackable_type: activity.trackable_type,
                trackable_name: activity.trackable_name,
                created_at: activity.created_at
              }
            end
  end

  def projects_by_status
    Project.where(user_id: current_user.id)
            .group(:status)
            .count
            .transform_keys { |status| status.presence || 'Not Started' }
  end

  def tasks_by_priority
    Task.joins(:project)
        .where(projects: { user_id: current_user.id })
        .group('tasks.priority')
        .count
        .transform_keys { |priority| priority.presence || 'Medium' }
  end

  def calculate_time_logged_this_week
    start_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week

    Task.joins(:project)
        .where(projects: { user_id: current_user.id })
        .where('tasks.created_at >= ? AND tasks.created_at <= ?', start_of_week, end_of_week)
        .count
  end
end
