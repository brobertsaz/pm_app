module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: [:current]
      before_action :authenticate_user!, only: [:index]

      def current
        if current_user
          render json: {
            id: current_user.id,
            email: current_user.email,
            full_name: current_user.full_name
          }
        else
          render json: { error: 'Not authenticated' }, status: :unauthorized
        end
      end

      def index
        @users = User.select(:id, :email).map do |user|
          {
            id: user.id,
            full_name: user.full_name,
            email: user.email
          }
        end
        render json: @users
      end
    end
  end
end
