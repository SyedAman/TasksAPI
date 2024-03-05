module Api
  class TasksController < ApplicationController
    before_action :set_task, only: %i[update destroy assign progress]

    def create
      task = Task.new(task_params)
      if task.save
        render json: task, status: :created
      else
        render json: task.errors, status: :unprocessable_entity
      end
    end

    def update
      if @task.update(task_params)
        @task.completed_date = Time.current if task_params[:status] == 'completed'
        @task.save
        render json: @task
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    # @TODO: Add other controller actions (destroy, assign, etc.) here.

    private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description, :due_date, :status, :priority)
    end
  end
end
