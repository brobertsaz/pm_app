module Api
  module V1
    class CalendarController < ApplicationController
      # GET /api/v1/calendar/events
      def events
        start_date = params[:start].present? ? Date.parse(params[:start]) : Date.today.beginning_of_month
        end_date = params[:end].present? ? Date.parse(params[:end]) : Date.today.end_of_month
        project_id = params[:project_id]

        tasks = fetch_tasks(start_date, end_date, project_id)
        projects_with_deadlines = fetch_projects(start_date, end_date, project_id)

        events = build_task_events(tasks) + build_project_events(projects_with_deadlines)

        render json: { events: events, success: true }
      rescue StandardError => e
        render json: { error: e.message, success: false }, status: :unprocessable_entity
      end

      private

      def fetch_tasks(start_date, end_date, project_id)
        tasks = policy_scope(Task).includes(:project, :user)

        if project_id.present?
          tasks = tasks.where(project_id: project_id)
        end

        tasks.where('due_date IS NOT NULL AND due_date BETWEEN ? AND ?', start_date, end_date)
      end

      def fetch_projects(start_date, end_date, project_id)
        projects = policy_scope(Project)

        if project_id.present?
          projects = projects.where(id: project_id)
        end

        projects.where('due_date IS NOT NULL AND due_date BETWEEN ? AND ?', start_date, end_date)
      end

      def build_task_events(tasks)
        tasks.map do |task|
          {
            id: "task-#{task.id}",
            title: task.title,
            start: task.due_date.iso8601,
            end: task.due_date.iso8601,
            extendedProps: {
              type: 'task',
              projectId: task.project_id,
              projectName: task.project.name,
              status: task.status,
              priority: task.priority,
              description: task.description,
              assignee: task.user&.email
            },
            backgroundColor: priority_color(task.priority),
            borderColor: priority_color(task.priority),
            textColor: '#fff'
          }
        end
      end

      def build_project_events(projects)
        projects.map do |project|
          {
            id: "project-#{project.id}",
            title: "#{project.name} (Deadline)",
            start: project.due_date.iso8601,
            end: project.due_date.iso8601,
            extendedProps: {
              type: 'project',
              projectId: project.id,
              status: project.status,
              priority: project.priority,
              description: project.description
            },
            backgroundColor: project_priority_color(project.priority),
            borderColor: project_priority_color(project.priority),
            textColor: '#fff'
          }
        end
      end

      def priority_color(priority)
        case priority
        when 'High'
          '#ef5350'
        when 'Medium'
          '#ffa726'
        when 'Low'
          '#66bb6a'
        else
          '#90caf9'
        end
      end

      def project_priority_color(priority)
        case priority
        when 'High'
          '#d32f2f'
        when 'Medium'
          '#f57c00'
        when 'Low'
          '#388e3c'
        else
          '#1976d2'
        end
      end
    end
  end
end
