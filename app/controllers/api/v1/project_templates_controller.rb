module Api
  module V1
    class ProjectTemplatesController < BaseController
      before_action :set_template, only: [:show, :update, :destroy, :instantiate]
      before_action :authorize_template, only: [:update, :destroy]

      def index
        @templates = current_user.project_templates.includes(:template_tasks).recent
        render json: @templates.as_json(include: :template_tasks)
      end

      def public_templates
        @templates = ProjectTemplate.public_templates.includes(:template_tasks).recent
        render json: @templates.as_json(include: :template_tasks)
      end

      def show
        render json: @template.as_json(
          include: {
            template_tasks: { only: [:id, :title, :description, :status, :priority, :position] },
            user: { only: [:id, :email] }
          }
        )
      end

      def create
        @template = current_user.project_templates.build(template_params)

        if @template.save
          render json: @template, status: :created
        else
          render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @template.update(template_params)
          render json: @template
        else
          render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @template.destroy
        head :no_content
      end

      def instantiate
        project_name = params[:project_name] || @template.name
        @project = @template.create_project(current_user, project_name)

        if @project.persisted?
          render json: {
            project: @project.as_json(
              include: { tasks: { only: [:id, :title, :status, :priority] } },
              methods: [:completion_percentage]
            ),
            message: "Project created from template successfully"
          }, status: :created
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def from_project
        project = Project.find(params[:project_id])
        authorize_project!(project)

        @template = current_user.project_templates.build(
          name: "#{project.name} Template",
          description: project.description,
          is_public: params[:is_public] || false
        )

        # Create template tasks from project tasks
        project.tasks.each do |task|
          @template.template_tasks.build(
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            position: task.position
          )
        end

        if @template.save
          render json: @template.as_json(include: :template_tasks), status: :created
        else
          render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_template
        @template = ProjectTemplate.find(params[:id])
      end

      def authorize_template
        unless @template.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def authorize_project!(project)
        unless project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def template_params
        params.require(:project_template).permit(:name, :description, :is_public, template_tasks_attributes: [:id, :title, :description, :status, :priority, :position, :_destroy])
      end
    end
  end
end
