class ProjectMailer < ApplicationMailer
  default queue: 'notifications'

  # Notify user when a project is created
  def project_created(project, user)
    @project = project
    @user = user
    @action_url = project_url(project, host: Rails.application.config.action_mailer.default_url_options[:host])

    mail(to: user.email, subject: "New Project Created: #{project.name}")
  end

  # Notify user when a project is updated
  def project_updated(project, user)
    @project = project
    @user = user
    @action_url = project_url(project, host: Rails.application.config.action_mailer.default_url_options[:host])

    mail(to: user.email, subject: "Project Updated: #{project.name}")
  end

  # Notify member when assigned to a project
  def project_assigned(project, member)
    @project = project
    @user = member
    @action_url = project_url(project, host: Rails.application.config.action_mailer.default_url_options[:host])

    mail(to: member.email, subject: "You've been assigned to project: #{project.name}")
  end

  # Notify project stakeholders about upcoming deadline
  def project_deadline_reminder(project)
    @project = project
    @users = project.members.where(project_members: { role: ['owner', 'admin'] })
    @action_url = project_url(project, host: Rails.application.config.action_mailer.default_url_options[:host])
    @days_until_due = (@project.due_date - Date.today).to_i if @project.due_date

    return if @users.empty?

    @users.each do |user|
      @user = user
      mail(to: user.email, subject: "Reminder: Project '#{project.name}' due in #{@days_until_due} days")
    end
  end
end
