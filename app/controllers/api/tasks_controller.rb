module Api
  class TasksController < ApplicationController
    before_action :set_task, only: %i[update destroy assign progress]

    def create
      task = Task.new(task_params.merge(user_id: params.dig(:task, :user_id)))
      if task.save
        render json: task, status: :created
      else
        render json: task.errors, status: :unprocessable_entity
      end
    end

    def update
      if @task.update(task_params)
        @task.completed_date = Time.current if @task.status == 'completed' && task_params[:status] == 'completed'
        @task.save
        render json: @task
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @task.destroy
      head :no_content
    end

    def assign
      # Assign a user to a task
      user = User.find(params[:user_id])
      @task.update(user_id: user.id)
      render json: @task
    end

    def progress
      if params[:task][:progress].to_i.between?(0, 100) # Ensuring progress is between 0 and 100
        @task.update(progress: params[:task][:progress])
        render json: @task
      else
        render json: { error: 'Progress must be between 0 and 100' }, status: :unprocessable_entity
      end
    end

    private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description, :due_date, :status, :priority)
    end
  end
end
