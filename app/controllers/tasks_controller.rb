class TasksController < ApplicationController
  def new
    @task = Task.new
    render :form
  end

  def index
	init_sorting_criteria
	# Just the tasks of the current user
	# Works because of the has_many relation
    @tasks = current_user.tasks
	if @asc then
		case @order_by
		when 0
			# Order by due date
			@tasks = @tasks.sort_by {|task| [task.isDone ? 1 : 0, task.due_date ? 0 : 1, task.due_date]}
		when 1
			# Order by priority
			@tasks = @tasks.sort_by {|task| [task.isDone ? 1 : 0, task.priority ? 0 : 1, task.priority]}
		when 2
			# Order by title
			@tasks = @tasks.sort_by {|task| [task.isDone ? 1 : 0, task.title ? 0 : 1, task.title]}
		when 3
			# Order by category name
			@tasks = @tasks.sort_by {|task| [task.isDone ? 1 : 0, task.category&.name ? 0 : 1, task.category&.name]}
		end
	else
		case @order_by
		when 0
			# Order by due date
			@tasks = @tasks.sort_by {|task| [task.isDone ? 0 : 1, task.due_date ? 0 : 1, task.due_date]}
		when 1
			# Order by priority
			@tasks = @tasks.sort_by {|task| [task.isDone ? 0 : 1, task.priority ? 0 : 1, task.priority]}
		when 2
			# Order by title
			@tasks = @tasks.sort_by {|task| [task.isDone ? 0 : 1, task.title ? 0 : 1, task.title]}
		when 3
			# Order by category name
			@tasks = @tasks.sort_by {|task| [task.isDone ? 0 : 1, task.category&.name ? 0 : 1, task.category&.name]}
		end
		@tasks = @tasks.reverse
	end
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
	redirect_back(fallback_location: '/')
  end
  
  # IDK if this is how I should implement the status_flip, I was able to add another column for 'isDone'
  def status_flip
    @task = Task.find(params[:id])
    authorize! :status_flip, @task
    @task.toggle(:isDone).save
    @tasks = Task.accessible_by(current_ability)
	redirect_back(fallback_location: '/')
  end

  def save_task
    if @task.save
      @tasks = Task.accessible_by(current_ability)
      redirect_to '/'
    else
      render :form
    end
  end

  def task_params
	# If we want to use a param (e.g. description), we have to permit the usage
    params.require(:task).permit(:title, :description, :category_id, :due_date, :isDone, :priority)
  end
  
  def init_sorting_criteria
	@sorting_criterias = [
		Criteria.new(0, "Due date"),
		Criteria.new(1, "Priority"),
		Criteria.new(2, "Title"),
		Criteria.new(3, "Category")
	]
	if params[:asc].nil? then
		@asc = true
	else
		# Ascending is default, if asc is neither 'true' nor 'false'
		@asc = params[:asc].to_s.downcase != "false"
	end
	
	@order_by = params[:order_by]
	# If order by is not set or invalid, set it to 0
	if @order_by.nil? || @order_by.to_i.to_s != @order_by then
		@order_by = "0"
	end
	# Convert the string to integer
	@order_by = @order_by.to_i
	# If order by is invalid set it to 0
	if 0 > @order_by || @order_by > 3 then
		@order_by = 0
	end
	# Select the attribute to order by
	@sorting_criterias[@order_by].select
  end
  
  class Criteria
	  attr_accessor :value, :name, :selected

	  def initialize(v, n)
		@value = v
		@name = n
		@selected = false
	  end
	  
	  def select
		@selected = true
	  end
  end
end