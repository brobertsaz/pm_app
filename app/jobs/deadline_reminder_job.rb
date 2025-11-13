class DeadlineReminderJob < ApplicationJob
  queue_as :reminders

  sidekiq_options retry: 3

  # Check for tasks due tomorrow
  def perform
    check_task_reminders
    check_project_reminders
  end

  private

  def check_task_reminders
    # Find tasks that are due tomorrow
    tomorrow = Date.tomorrow
    tasks_due_tomorrow = Task.where(due_date: tomorrow)
                             .where(status: ['To Do', 'In Progress'])

    tasks_due_tomorrow.each do |task|
      TaskMailer.task_due_soon(task).deliver_later if task.user.present?
    end

    # Find overdue tasks (that became overdue in the last day)
    today = Date.today
    overdue_tasks = Task.where("due_date < ?", today)
                        .where(status: ['To Do', 'In Progress'])

    overdue_tasks.each do |task|
      TaskMailer.task_overdue(task).deliver_later if task.user.present?
    end
  end

  def check_project_reminders
    # Find projects with due dates coming up (within 3 days)
    upcoming_date = Date.today + 3.days
    projects_with_upcoming_deadlines = Project.where("due_date <= ?", upcoming_date)
                                              .where("due_date > ?", Date.today)
                                              .where(status: ['Not Started', 'In Progress'])

    projects_with_upcoming_deadlines.each do |project|
      ProjectMailer.project_deadline_reminder(project).deliver_later
    end
  end
end
