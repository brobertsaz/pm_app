module Api
  module V1
    class FilesController < BaseController
      before_action :set_attachable
      before_action :set_attachment, only: [:destroy, :download]
      before_action :authorize_attachable, only: [:create, :destroy]

      def index
        attachments = @attachable.files.map do |file|
          {
            id: file.id,
            filename: file.filename.to_s,
            byte_size: file.byte_size,
            created_at: file.created_at
          }
        end
        render json: attachments
      end

      def create
        uploaded_files = []

        if params[:files].present?
          Array(params[:files]).each do |file|
            attachment = @attachable.files.attach(file)
            blob = attachment.blob
            uploaded_files << {
              id: blob.id,
              filename: blob.filename.to_s,
              byte_size: blob.byte_size,
              created_at: blob.created_at
            }
          end
        end

        render json: uploaded_files, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def destroy
        @attachment.purge
        head :no_content
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def download
        send_data @attachment.download,
                  filename: @attachment.filename.to_s,
                  type: @attachment.content_type,
                  disposition: 'attachment'
      rescue => e
        render json: { error: e.message }, status: :not_found
      end

      private

      def set_attachable
        if params[:project_id]
          @attachable = Project.find(params[:project_id])
        elsif params[:task_id]
          @attachable = Task.find(params[:task_id])
        end
      end

      def set_attachment
        @attachment = @attachable.files.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'File not found' }, status: :not_found
      end

      def authorize_attachable
        unless @attachable.user_id == current_user.id || @attachable.is_a?(Task) && @attachable.project.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end
