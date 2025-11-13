require 'csv'

class ExportsController < ApplicationController
  before_action :authenticate_user!

  # GET /exports/projects
  # Export all projects as CSV
  def projects_csv
    projects = policy_scope(Project).includes(:user, :tasks)

    csv_data = generate_projects_csv(projects)

    send_data csv_data,
              filename: "projects_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  # GET /exports/projects/:id
  # Export single project with tasks as PDF
  def project_pdf
    @project = Project.find(params[:id])
    authorize @project

    render pdf: "project_#{@project.id}",
           template: 'exports/project_pdf',
           layout: 'pdf',
           margin: { top: 10, bottom: 10, left: 10, right: 10 }
  end

  # GET /exports/tasks
  # Export all tasks as CSV
  def tasks_csv
    tasks = policy_scope(Task).includes(:project, :user)

    csv_data = generate_tasks_csv(tasks)

    send_data csv_data,
              filename: "tasks_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  # GET /exports/time_entries
  # Export all time entries as CSV
  def time_entries_csv
    time_entries = TimeEntry.includes(:task, :user)
                             .joins(:task)
                             .where(tasks: { project_id: policy_scope(Project).pluck(:id) })

    csv_data = generate_time_entries_csv(time_entries)

    send_data csv_data,
              filename: "time_entries_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  # GET /exports/project_report
  # Export comprehensive project report with all data
  def project_report_pdf
    @project = Project.find(params[:project_id])
    authorize @project

    @tasks = @project.tasks.ordered
    @time_entries = TimeEntry.joins(:task).where(tasks: { project_id: @project.id })
    @completed_tasks = @tasks.where(status: 'Done').count
    @total_hours = @time_entries.sum(:hours)

    render pdf: "project_report_#{@project.id}",
           template: 'exports/project_report_pdf',
           layout: 'pdf',
           margin: { top: 10, bottom: 10, left: 10, right: 10 }
  end

  private

  def generate_projects_csv(projects)
    CSV.generate(headers: true) do |csv|
      csv << [
        'ID',
        'Name',
        'Description',
        'Status',
        'Priority',
        'Owner',
        'Due Date',
        'Created At',
        'Updated At',
        'Completion %',
        'Total Tasks',
        'Completed Tasks'
      ]

      projects.each do |project|
        csv << [
          project.id,
          project.name,
          project.description,
          project.status,
          project.priority,
          project.user&.email,
          project.due_date&.strftime('%Y-%m-%d'),
          project.created_at&.strftime('%Y-%m-%d %H:%M'),
          project.updated_at&.strftime('%Y-%m-%d %H:%M'),
          project.completion_percentage,
          project.tasks.count,
          project.tasks.where(status: 'Done').count
        ]
      end
    end
  end

  def generate_tasks_csv(tasks)
    CSV.generate(headers: true) do |csv|
      csv << [
        'ID',
        'Title',
        'Project',
        'Status',
        'Priority',
        'Assignee',
        'Due Date',
        'Description',
        'Created At',
        'Updated At',
        'Total Hours Logged'
      ]

      tasks.each do |task|
        csv << [
          task.id,
          task.title,
          task.project.name,
          task.status,
          task.priority,
          task.user&.email,
          task.due_date&.strftime('%Y-%m-%d'),
          truncate_text(task.description),
          task.created_at&.strftime('%Y-%m-%d %H:%M'),
          task.updated_at&.strftime('%Y-%m-%d %H:%M'),
          task.total_time_logged
        ]
      end
    end
  end

  def generate_time_entries_csv(time_entries)
    CSV.generate(headers: true) do |csv|
      csv << [
        'ID',
        'Task',
        'Project',
        'User',
        'Hours',
        'Logged Date',
        'Description',
        'Created At'
      ]

      time_entries.each do |entry|
        csv << [
          entry.id,
          entry.task.title,
          entry.task.project.name,
          entry.user.email,
          entry.hours,
          entry.logged_date&.strftime('%Y-%m-%d'),
          truncate_text(entry.description),
          entry.created_at&.strftime('%Y-%m-%d %H:%M')
        ]
      end
    end
  end

  def truncate_text(text, length = 50)
    return '' if text.blank?
    text.length > length ? text[0...length] + '...' : text
  end
end
