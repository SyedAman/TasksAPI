require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  # Add your tests here, for example:
  describe 'POST /api/tasks' do
    let(:valid_attributes) { { title: 'Test Task', description: 'Test Description', due_date: Time.zone.tomorrow } }

    context 'when the request is valid' do
      before { post '/api/tasks', params: valid_attributes }

      it 'creates a task' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/tasks', params: { title: 'Only Title' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Add similar tests for update, delete, assign, etc.
end
