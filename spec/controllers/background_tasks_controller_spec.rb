# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackgroundTasksController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:background_tasks) { double('background_tasks') }
    before(:each) do
      allow(background_tasks).to receive(:order_by).and_return(background_tasks)
      allow(background_tasks).to receive(:page).and_return(background_tasks)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of background_tasks' do
      background_task = FactoryBot.create(:default_background_task)
      get :index
      expect(assigns(:background_tasks)).to include(background_task)
    end
    it 'stores filters to the session' do
      get :index, params: { with_task_type: 'type' }
      expect(session[:filter_background_tasks].except(:order_by)).to eq('with_task_type' => 'type')
    end
    it 'removes blank filter values' do
      get :index, params: { with_task_type: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_background_task, task_type: :retrieve_footfall_data)
      FactoryBot.create(:default_background_task, task_type: :raise_alarms)
      get :index, params: {}, session: { filter_background_tasks: { with_task_type: :retrieve_footfall_data } }
      expect(assigns(:background_tasks)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_background_tasks]).to include(order_by: 'id desc')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_background_task, started_at: 1.minute.ago)
      a = FactoryBot.create(:default_background_task, started_at: 2.minutes.ago)
      get :index, params: { order_by: 'started_at asc' }
      expect(assigns(:background_tasks)).to eq([a, b])
    end
    it "applies the 'with_task_type' filter" do
      expect(BackgroundTask).to receive(:with_task_type).with('type').and_return(background_tasks)
      get :index, params: { with_task_type: 'type' }
    end
    it "applies the 'with_status' filter" do
      expect(BackgroundTask).to receive(:with_status).with('running').and_return(background_tasks)
      get :index, params: { with_status: 'running' }
    end
    it "applies the 'with_outcome' filter" do
      expect(BackgroundTask).to receive(:with_outcome).with('success').and_return(background_tasks)
      get :index, params: { with_outcome: 'success' }
    end
    context 'applies paging' do
      before(:each) do
        Kaminari.configure do |config|
          @default_per_page = config.default_per_page
          config.default_per_page = 2
        end
      end
      after(:each) do
        Kaminari.configure do |config|
          config.default_per_page = @default_per_page
        end
      end
      context 'with no explicit page value' do
        it 'returns the first page of background_tasks' do
          3.times { |_i| FactoryBot.create(:default_background_task) }
          get :index
          expect(assigns(:background_tasks).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        it 'returns the requested page of background_tasks' do
          3.times { |_i| FactoryBot.create(:default_background_task) }
          get :index, params: { page: 2 }
          expect(assigns(:background_tasks).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(background_tasks_path)
    end
    it 'clears the session entry' do
      session[:filter_background_tasks] = { 'with_task_type' => :retrieve_footfall_data }
      get :clear_filter
      expect(session.key?(:filter_background_tasks)).to be false
    end
  end

  describe 'GET #show' do
    let(:background_task) { FactoryBot.create(:default_background_task) }
    it 'shows a record' do
      get(:show, params: { id: background_task.id })
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:background_task).id).to eq(background_task.id)
      expect(assigns(:title)).to eq('Background task details')
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, params: { id: 99 })
      end
    end
  end

  describe 'GET #new' do
    it 'renders a blank form' do
      get :new
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:background_task).id).to be_nil
      expect(assigns(:title)).to eq('New background task')
      expect(assigns(:cancel_path)).to eq(background_tasks_path)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      let(:background_task) { BackgroundTask.order(:id).last }
      def post_create
        attrs = {
          task_type: 'retrieve_footfall_data'
        }
        post(:create, params: { background_task: attrs })
      end
      before(:each) do
        allow_any_instance_of(BackgroundTask).to receive(:schedule_task) do
          @scheduled = true
        end
        post_create
      end
      it 'creates a new record' do
        expect do
          post_create
        end.to change(BackgroundTask, :count).by(1)
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(background_task_path(background_task))
      end
      it 'set a flash message' do
        expect(flash[:notice]).to eq('Background task was created successfully')
      end
      it 'stores task type' do
        expect(background_task.retrieve_footfall_data?).to be_truthy
      end
      it 'schedules the task' do
        expect(@scheduled).to be_truthy
      end
    end
    context 'with invalid data' do
      def post_create
        post(:create, params: { background_task: { task_type: nil } })
      end
      it 'does not create a new record' do
        expect do
          post_create
        end.to_not change(BackgroundTask, :count)
      end
      it 're-renders the form with the posted data and title' do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:title)).to eq('New background task')
        expect(assigns(:cancel_path)).to eq(background_tasks_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:background_task) { FactoryBot.create(:default_background_task) }
    it 'deletes the record' do
      expect do
        delete(:destroy, params: { id: background_task.id })
      end.to change(BackgroundTask, :count).by(-1)
    end
    it 'redirects to #index' do
      delete(:destroy, params: { id: background_task.id })
      expect(response).to redirect_to(background_tasks_path)
    end
  end
end
