class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    @project_count = current_user.projects.count
    @task_count = Task.joins(:project).where(projects: { user_id: current_user.id }).count
    @completed_projects = current_user.projects.where(status: 'Completed').count
    @completed_tasks = Task.joins(:project).where(projects: { user_id: current_user.id }, status: 'Done').count
  end

  def project_performance
    @projects = current_user.projects.includes(:tasks)

    render json: {
      projects: @projects.map { |project|
        {
          id: project.id,
          name: project.name,
          status: project.status,
          completion_percentage: project.completion_percentage,
          total_tasks: project.tasks.count,
          completed_tasks: project.tasks.where(status: 'Done').count,
          in_progress_tasks: project.tasks.where(status: 'In Progress').count,
          to_do_tasks: project.tasks.where(status: 'To Do').count,
          created_at: project.created_at,
          updated_at: project.updated_at
        }
      }
    }
  end

  def time_reports
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 1.month.ago
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    @time_entries = TimeEntry.joins(task: :project)
                              .where(projects: { user_id: current_user.id })
                              .where(created_at: start_date..end_date)
                              .includes(task: :project)

    projects_time = @time_entries.group_by { |entry| entry.task.project }
                                 .map { |project, entries|
                                   {
                                     project_id: project.id,
                                     project_name: project.name,
                                     total_hours: entries.sum(&:hours),
                                     entry_count: entries.count,
                                     average_hours: (entries.sum(&:hours) / entries.count.to_f).round(2)
                                   }
                                 }

    users_time = @time_entries.group_by { |entry| entry.user }
                               .map { |user, entries|
                                 {
                                   user_id: user.id,
                                   user_email: user.email,
                                   total_hours: entries.sum(&:hours),
                                   entry_count: entries.count,
                                   average_hours: (entries.sum(&:hours) / entries.count.to_f).round(2)
                                 }
                               }

    render json: {
      start_date: start_date,
      end_date: end_date,
      projects_time: projects_time,
      users_time: users_time,
      total_hours: @time_entries.sum(&:hours)
    }
  end

  def team_productivity
    @projects_with_members = current_user.projects.includes(:members, :tasks)

    team_stats = @projects_with_members.map { |project|
      {
        project_id: project.id,
        project_name: project.name,
        team_members: project.members.map { |member|
          completed_tasks = Task.where(project: project, user: member, status: 'Done').count
          total_tasks = Task.where(project: project, user: member).count
          total_time = TimeEntry.where(user: member).joins(task: :project)
                                 .where(projects: { id: project.id }).sum(:hours)

          {
            user_id: member.id,
            user_email: member.email,
            completed_tasks: completed_tasks,
            total_tasks: total_tasks,
            completion_rate: total_tasks.zero? ? 0 : ((completed_tasks.to_f / total_tasks) * 100).round(2),
            total_time_logged: total_time.round(2)
          }
        }
      }
    }

    render json: { team_productivity: team_stats }
  end

  def burndown_chart
    project = Project.find(params[:project_id])
    authorize_project!(project)

    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : project.created_at.to_date
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # Get daily snapshot of remaining tasks
    daily_remaining = {}
    (start_date..end_date).each do |date|
      # Count tasks that were not completed by this date
      remaining = Task.where(project: project)
                      .where("created_at <= ?", date)
                      .where("(status != 'Done' OR updated_at > ?)", date)
                      .count

      # Subtract tasks that were completed on or before this date
      completed = Task.where(project: project)
                      .where("updated_at <= ?", date)
                      .where(status: 'Done')
                      .count

      daily_remaining[date.to_s] = [remaining - completed, 0].max
    end

    total_tasks = project.tasks.count
    ideal_remaining = {}
    days_span = (end_date - start_date).to_i + 1

    (0..days_span).each do |day|
      date = start_date + day.days
      ideal = ((total_tasks * (days_span - day)) / days_span).round
      ideal_remaining[date.to_s] = [ideal, 0].max
    end

    render json: {
      project_id: project.id,
      project_name: project.name,
      start_date: start_date,
      end_date: end_date,
      total_tasks: total_tasks,
      actual_remaining: daily_remaining,
      ideal_remaining: ideal_remaining
    }
  end

  private

  def authorize_project!(project)
    unless project.user_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
