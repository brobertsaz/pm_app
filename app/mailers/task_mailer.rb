class TaskMailer < ApplicationMailer
  default queue: 'notifications'

  # Notify user when a task is created
  def task_created(task, user)
    @task = task
    @project = task.project
    @user = user
    @action_url = project_task_url(@project, @task, host: Rails.application.config.action_mailer.default_url_options[:host])

    mail(to: user.email, subject: "New Task Created: #{task.title}")
  end

  # Notify user when assigned to a task
  def task_assigned(task, user)
    @task = task
    @project = task.project
    @user = user
    @action_url = project_task_url(@project, @task, host: Rails.application.config.action_mailer.default_url_options[:host])

    mail(to: user.email, subject: "Task Assigned to You: #{task.title}")
  end

  # Notify watchers when task is completed
  def task_completed(task)
    @task = task
    @project = task.project
    @action_url = project_task_url(@project, @task, host: Rails.application.config.action_mailer.default_url_options[:host])

    # Send to project members
    @project.members.each do |user|
      @user = user
      mail(to: user.email, subject: "Task Completed: #{task.title}")
    end
  end

  # Notify assigned user when task is overdue
  def task_overdue(task)
    @task = task
    @project = task.project
    @user = task.user
    @days_overdue = (Date.today - @task.due_date).to_i if @task.due_date
    @action_url = project_task_url(@project, @task, host: Rails.application.config.action_mailer.default_url_options[:host])

    return unless @user.present?

    mail(to: @user.email, subject: "Overdue Task: #{task.title} (#{@days_overdue} days overdue)")
  end

  # Notify assigned user when task is due soon (1 day before)
  def task_due_soon(task)
    @task = task
    @project = task.project
    @user = task.user
    @action_url = project_task_url(@project, @task, host: Rails.application.config.action_mailer.default_url_options[:host])

    return unless @user.present?

    mail(to: @user.email, subject: "Task Due Tomorrow: #{task.title}")
  end
end
