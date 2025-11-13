class CalendarController < ApplicationController
  # GET /calendar
  def index
    @projects = policy_scope(Project).includes(:tasks)
    @current_month = params[:month].present? ? Date.parse(params[:month]) : Date.today
  end
end
