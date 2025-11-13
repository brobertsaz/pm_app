class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  # GET /projects/:project_id/tasks
  def index
    authorize Task
    @tasks = @project.tasks.ordered
  end

  # GET /projects/:project_id/tasks/:id
  def show
    authorize @task
  end

  # GET /projects/:project_id/tasks/new
  def new
    @task = @project.tasks.build
    authorize @task
  end

  # GET /projects/:project_id/tasks/:id/edit
  def edit
    authorize @task
  end

  # POST /projects/:project_id/tasks
  def create
    @task = @project.tasks.build(task_params)
    @task.user = current_user
    authorize @task

    if @task.save
      redirect_to project_path(@project), notice: 'Task was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:project_id/tasks/:id
  def update
    authorize @task

    if @task.update(task_params)
      redirect_to project_path(@project), notice: 'Task was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/tasks/:id
  def destroy
    authorize @task
    @task.destroy
    redirect_to project_path(@project), notice: 'Task was successfully destroyed.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :position)
  end
end
