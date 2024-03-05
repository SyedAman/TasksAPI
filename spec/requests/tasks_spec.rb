require 'rails_helper'

# Create Task (POST /api/tasks)
describe 'POST /api/tasks', type: :request do
  let(:valid_attributes) { { title: 'New Task', description: 'Task Description', due_date: '2023-12-31' } }

  context 'when the request is valid' do
    before { post '/api/tasks', params: valid_attributes }

    it 'creates a new task' do
      expect(response).to have_http_status(201)
      expect(json['title']).to eq('New Task')
    end
  end

  context 'when the request is invalid' do
    before { post '/api/tasks', params: { title: 'Only Title' } } # assuming description and due_date are required

    it 'returns status code 422' do
      expect(response).to have_http_status(422)
      expect(response.body).to match(/Validation failed/)
    end
  end
end

# Update Task (PUT /api/tasks/{taskId})
describe 'PUT /api/tasks/:id', type: :request do
  let!(:task) { create(:task) }
  let(:valid_attributes) { { title: 'Updated Task', description: 'Updated Description', due_date: '2023-12-31', status: 'completed' } }

  context 'when the record exists' do
    before { put "/api/tasks/#{task.id}", params: valid_attributes }

    it 'updates the record' do
      expect(response).to have_http_status(200)
      expect(task.reload.status).to eq('completed')
      expect(task.completed_date).not_to be_nil
    end
  end
end

# Delete Task (DELETE /api/tasks/{taskId})
describe 'DELETE /api/tasks/:id', type: :request do
  let!(:task) { create(:task) }

  before { delete "/api/tasks/#{task.id}" }

  it 'deletes the task' do
    expect(response).to have_http_status(204)
    expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
    expect(task.reload.user).to eq(user)
  end
end

# Get User's Assigned Tasks (GET /api/users/{userId}/tasks)
describe 'GET /api/users/:user_id/tasks', type: :request do
  let!(:user) { create(:user) }
  let!(:tasks) { create_list(:task, 5, user: user) }

  before { get "/api/users/#{user.id}/tasks" }

  it 'returns tasks for the specified user' do
    expect(response).to have_http_status(200)
    expect(json.size).to eq(5)  # Assuming json is a helper method to parse JSON responses
  end
end
