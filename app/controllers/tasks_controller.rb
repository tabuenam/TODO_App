# class TasksController < ApplicationController
#   before_action :set_task, only: [:show, :edit, :update, :destroy]




#   # GET /tasks
#   # GET /tasks.json
#   def index
#     @tasks = Task.all
#   end

#   # GET /tasks/1
#   # GET /tasks/1.json
#   def show
#   end

#   # GET /tasks/new
#   def new
#     @task = Task.new
#   end

#   # GET /tasks/1/edit
#   def edit
#   end

#   # POST /tasks
#   # POST /tasks.json
#   def create
#     @task = Task.new(task_params)

#     respond_to do |format|
#       if @task.save
#         format.html { redirect_to @task, notice: 'Task was successfully created.' }
#         format.json { render :show, status: :created, location: @task }
#       else
#         format.html { render :new }
#         format.json { render json: @task.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # PATCH/PUT /tasks/1
#   # PATCH/PUT /tasks/1.json
#   def update
#     respond_to do |format|
#       if @task.update(task_params)
#         format.html { redirect_to @task, notice: 'Task was successfully updated.' }
#         format.json { render :show, status: :ok, location: @task }
#       else
#         format.html { render :edit }
#         format.json { render json: @task.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # DELETE /tasks/1
#   # DELETE /tasks/1.json
#   def destroy
#     @task.destroy
#     respond_to do |format|
#       format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
#       format.json { head :no_content }
#     end
#   end

#   private
#     # Use callbacks to share common setup or constraints between actions.
#     def set_task
#       @task = Task.find(params[:id])
#     end

#     # Only allow a list of trusted parameters through.
#     def task_params
#       params.require(:task).permit(:title, :description)
#     end
# end


class TasksController < ApplicationController
  def new
    @task = Task.new
    render :form
  end

  def index
	 // Just the tasks of the current user
	 // Works because of the has_many relation
     @tasks = current_user.tasks
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user
    authorize! :create, @task
    save_task
  end

  def edit
    @task = Task.find(params[:id])
    authorize! :edit, @task
    render :form
  end

  def update
    @task = Task.find(params[:id])
    @task.assign_attributes(task_params)
    authorize! :update, @task
    save_task
  end

  def destroy
    @task = Task.find(params[:id])
    authorize! :destroy, @task
    @task.destroy
    @tasks = Task.accessible_by(current_ability)
  end

  private

  def save_task
    if @task.save
      @tasks = Task.accessible_by(current_ability)
      render :index
    else
      render :form
    end
  end

  def task_params
	// If we want to use a param (e.g. description), we have to permit the usage
    params.require(:task).permit(:title, :description)
  end
end