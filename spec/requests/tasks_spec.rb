require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  # Create Task
  describe 'POST /api/tasks' do
    let(:valid_attributes) do
      { task: attributes_for(:task).merge(user_id: user_id) }
    end

    context 'when the request is valid' do
      before { post '/api/tasks', params: valid_attributes }

      it 'creates a new task' do
        expect(response).to have_http_status(201)
        expect(json['title']).to eq('Sample Task')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/tasks', params: { task: { title: 'Only Title', user_id: user_id } } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
        expect(response.body).to include("can't be blank")
      end
    end
  end

  # Update Task
  describe 'PUT /api/tasks/:id' do
    let(:task) { create(:task, user: user) }
    let(:valid_attributes) do
      { task: { title: 'Updated Task', status: 'completed' } }
    end

    context 'when the record exists' do
      before { put "/api/tasks/#{task.id}", params: valid_attributes }

      it 'updates the record' do
        updated_task = Task.find(task.id)
        expect(response).to have_http_status(200)
        expect(updated_task.title).to match(/Updated Task/)
      end
    end
  end

  # Delete Task (DELETE /api/tasks/{taskId})
  describe 'DELETE /api/tasks/:id', type: :request do
    let!(:task) { create(:task) }

    before { delete "/api/tasks/#{task.id}" }

    it 'deletes the task' do
      expect(response).to have_http_status(204)
      expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  # Get All Tasks (GET /api/tasks)
  describe 'GET /api/tasks', type: :request do
    before do
      create_list(:task, 5)
      get '/api/tasks'
    end

    it 'returns all tasks' do
      expect(response).to have_http_status(200)
      expect(json.size).to eq(5)
    end
  end

  # Assign Task (POST /api/tasks/{taskId}/assign)
  describe 'POST /api/tasks/:id/assign', type: :request do
    let!(:task) { create(:task) }
    let!(:user) { create(:user) }

    before { post "/api/tasks/#{task.id}/assign", params: { user_id: user.id } }

    it 'assigns the task to the user' do
      expect(response).to have_http_status(200)
      expect(Task.find(task.id).user).to eq(user)
    end
  end

  # Get User's Assigned Tasks (GET /api/users/{userId}/tasks)
  describe 'GET /api/users/:user_id/tasks', type: :request do
    let!(:user) { create(:user) }
    let!(:tasks) { create_list(:task, 5, user: user) }

    before { get "/api/users/#{user.id}/tasks" }

    it 'returns tasks for the specified user' do
      expect(response).to have_http_status(200)
      expect(json.size).to eq(5)
    end
  end

  # Set Task Progress (PUT /api/tasks/{taskId}/progress)
  describe 'PUT /api/tasks/:id/progress', type: :request do
    let!(:task) { create(:task) }

    context 'when the request is valid' do
      let(:valid_progress) do
        { task: { progress: 50 } }
      end

      before { put "/api/tasks/#{task.id}/progress", params: valid_progress }

      it 'updates the task progress' do
        expect(response).to have_http_status(200)
        expect(Task.find(task.id).progress).to eq(50)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_progress) do
        { task: { progress: 150 } } # Assuming progress cannot exceed 100
      end

      before { put "/api/tasks/#{task.id}/progress", params: invalid_progress }

      it 'returns a validation failure message' do
        expect(response).to have_http_status(422)
        expect(response.body).to match(/Validation failed/)
      end
    end
  end

  # Get Overdue Tasks (GET /api/tasks/overdue)
  describe 'GET /api/tasks/overdue', type: :request do
    before do
      create(:task, due_date: 1.day.ago, status: 'pending') # Overdue
      create(:task, due_date: 1.day.from_now, status: 'pending') # Not overdue
      get '/api/tasks/overdue'
    end

    it 'returns only overdue tasks' do
      expect(response).to have_http_status(200)
      expect(json.size).to eq(1)
      expect(json.first['status']).to eq('pending')
    end
  end

  # Get Tasks by Status (GET /api/tasks/status/{status})
  describe 'GET /api/tasks/status/:status', type: :request do
    before do
      create_list(:task, 3, status: 'completed')
      create_list(:task, 2, status: 'pending')
    end

    context 'when getting completed tasks' do
      before { get '/api/tasks/status/completed' }

      it 'returns all completed tasks' do
        expect(response).to have_http_status(200)
        expect(json.size).to eq(3)
        json.each do |task|
          expect(task['status']).to eq('completed')
        end
      end
    end

    context 'when getting pending tasks' do
      before { get '/api/tasks/status/pending' }

      it 'returns all pending tasks' do
        expect(response).to have_http_status(200)
        expect(json.size).to eq(2)
        json.each do |task|
          expect(task['status']).to eq('pending')
        end
      end
    end
  end

  # Get Completed Tasks by Date Range (GET /api/tasks/completed)
  describe 'GET /api/tasks/completed', type: :request do
    before do
      create(:task, status: 'completed', completed_date: Date.yesterday)
      create(:task, status: 'completed', completed_date: Date.today)
      create(:task, status: 'completed', completed_date: 2.days.ago) # Outside range
    end

    context 'when getting completed tasks within a date range' do
      before { get '/api/tasks/completed', params: { startDate: Date.yesterday, endDate: Date.today } }

      it 'returns completed tasks within the date range' do
        expect(response).to have_http_status(200)
        expect(json.size).to eq(2)
      end
    end
  end

  # Get Tasks Statistics (GET /api/tasks/statistics)
  describe 'GET /api/tasks/statistics', type: :request do
    before do
      create_list(:task, 5, status: 'completed')
      create_list(:task, 3, status: 'pending')
      get '/api/tasks/statistics'
    end

    it 'returns tasks statistics' do
      expect(response).to have_http_status(200)
      expect(json['total_tasks']).to eq(8)
      expect(json['completed_tasks']).to eq(5)
      expect(json['completion_percentage']).to eq(62.5)
    end
  end

  # Priority-based Task Queue
  describe 'GET /api/tasks', type: :request do
    before do
      create(:task, priority: 'high', due_date: 1.day.from_now)
      create(:task, priority: 'medium', due_date: 2.days.from_now)
      create(:task, priority: 'low', due_date: 3.days.from_now)
      get '/api/tasks'
    end

    it 'returns tasks ordered by priority and due date' do
      expect(response).to have_http_status(200)
      priorities = json.map { |t| t['priority'] }
      expect(priorities).to eq(['high', 'medium', 'low'])
    end
  end
end
