module Api
  module V1
    class SearchController < BaseController
      def index
        query = params[:q].to_s.strip
        search_type = (params[:searchType] || params[:search_type] || 'all').to_s.downcase

        results = []

        # Search Projects
        if search_type == 'all' || search_type == 'projects'
          projects = query.present? ? Project.search(query) : Project.all
          projects = apply_project_filters(projects)

          results.concat(projects.map { |p| format_project_result(p) })
        end

        # Search Tasks
        if search_type == 'all' || search_type == 'tasks'
          tasks = query.present? ? Task.search(query) : Task.all
          tasks = apply_task_filters(tasks)

          results.concat(tasks.map { |t| format_task_result(t) })
        end

        # Sort results by relevance and date
        results.sort_by! { |r| [-r[:relevance_score], -r[:created_at].to_time.to_i] }

        render json: { results: results }, status: :ok
      end

      private

      def apply_project_filters(projects)
        if params[:status].present?
          statuses = Array.wrap(params[:status])
          projects = projects.where(status: statuses) if statuses.any?
        end

        if params[:priority].present?
          priorities = Array.wrap(params[:priority])
          projects = projects.where(priority: priorities) if priorities.any?
        end

        if params[:start_date].present? || params[:end_date].present?
          projects = projects.by_date_range(params[:start_date], params[:end_date])
        end

        projects
      end

      def apply_task_filters(tasks)
        if params[:status].present?
          statuses = Array.wrap(params[:status])
          tasks = tasks.where(status: statuses) if statuses.any?
        end

        if params[:priority].present?
          priorities = Array.wrap(params[:priority])
          tasks = tasks.where(priority: priorities) if priorities.any?
        end

        tasks = tasks.where(user_id: params[:assigned_user]) if params[:assigned_user].present?

        if params[:tags].present?
          tag_ids = Array.wrap(params[:tags])
          if tag_ids.any?
            tasks = tasks.joins(:tags).where(tags: { id: tag_ids }).distinct
          end
        end

        if params[:start_date].present? || params[:end_date].present?
          tasks = tasks.by_date_range(params[:start_date], params[:end_date])
        end

        tasks
      end

      def format_project_result(project)
        {
          id: project.id,
          type: 'project',
          name: project.name,
          description: project.description,
          status: project.status,
          priority: project.priority,
          created_at: project.created_at,
          relevance_score: calculate_relevance(project.name, params[:q].to_s)
        }
      end

      def format_task_result(task)
        {
          id: task.id,
          type: 'task',
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          project_id: task.project_id,
          project_name: task.project.name,
          assigned_to: task.user&.full_name,
          due_date: task.due_date,
          created_at: task.created_at,
          tags: task.tags.map { |t| { id: t.id, name: t.name } },
          relevance_score: calculate_relevance(task.title, params[:q].to_s)
        }
      end

      def calculate_relevance(field, query)
        return 0 if query.blank? || field.blank?

        field_lower = field.downcase
        query_lower = query.downcase

        # Exact match scores highest
        return 100 if field_lower == query_lower

        # Word boundary match
        if field_lower.match?(/\b#{Regexp.escape(query_lower)}\b/)
          return 80
        end

        # Starts with query
        return 60 if field_lower.start_with?(query_lower)

        # Contains query
        return 40 if field_lower.include?(query_lower)

        0
      end
    end
  end
end
