# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:users) { double('users') }
    before(:each) do
      allow(users).to receive(:order_by).and_return(users)
      allow(users).to receive(:order).and_return(users)
      allow(users).to receive(:page).and_return(users)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of users' do
      user = FactoryBot.create(:default_user)
      get :index
      expect(assigns(:users)).to include(user)
    end
    it 'stores filters to the session' do
      get :index, params: { with_name: 'name' }
      expect(session[:filter_users].except(:order_by)).to eq('with_name' => 'name')
    end
    it 'removes blank filter values' do
      get :index, params: { with_name: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_user, first_name: 'xxx')
      FactoryBot.create(:default_user, first_name: 'yyy')
      get :index, params: {}, session: { filter_users: { with_name: 'xxx' } }
      expect(assigns(:users)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_users]).to include(order_by: 'first_name, last_name')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_user, email: 'b@example.com')
      a = FactoryBot.create(:default_user, email: 'a@example.com')
      c = FactoryBot.create(:default_user, email: 'c@example.com')
      get :index, params: { order_by: 'email desc' }
      expect(assigns(:users).without(subject.current_user)).to eq([c, b, a])
    end
    it "applies the 'with_name' filter" do
      expect(User).to receive(:with_name).with('name').and_return(users)
      get :index, params: { with_name: 'name' }
    end
    it "applies the 'with_email' filter" do
      expect(User).to receive(:with_email).with('email').and_return(users)
      get :index, params: { with_email: 'email' }
    end
    it "applies the 'with_role' filter" do
      expect(User).to receive(:with_role).with('administrator').and_return(users)
      get :index, params: { with_role: 'administrator' }
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
        # Will add the current user ... hence the filtering ...
        it 'returns the first page of users' do
          3.times { |_i| FactoryBot.create(:default_user, first_name: 'xxx') }
          get :index, params: { with_name: 'xxx' }
          expect(assigns(:users).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        # Will add the current user ... hence the filtering ...
        it 'returns the requested page of users' do
          3.times { |_i| FactoryBot.create(:default_user, first_name: 'xxx') }
          get :index, params: { with_name: 'xxx', page: 2 }
          expect(assigns(:users).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(users_path)
    end
    it 'clears the session entry' do
      session[:filter_users] = { 'with_name' => 'name' }
      get :clear_filter
      expect(session.key?(:filter_users)).to be false
    end
  end

  describe 'GET #show' do
    let(:user) { FactoryBot.create(:default_user, email: 'a@a.com') }
    it 'shows a record' do
      get(:show, params: { id: user.id })
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:user).id).to eq(user.id)
      expect(assigns(:title)).to eq('User details')
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
      expect(assigns(:user).id).to be_nil
      expect(assigns(:title)).to eq('New user')
      expect(assigns(:cancel_path)).to eq(users_path)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      let(:user) { User.order(:id).last }
      def post_create
        attrs = {
          email: 'a@b.com',
          first_name: 'John',
          last_name: 'Smith',
          password: 'HasToBeValid0',
          password_confirmation: 'HasToBeValid0',
          role: 'administrator'
        }
        post(:create, params: { user: attrs })
      end
      before(:each) do
        post_create
      end
      it 'creates a new record' do
        expect do
          post(:create, params: { user: FactoryBot.attributes_for(:default_user) })
        end.to change(User, :count).by(1)
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(user_path(user))
      end
      it 'set a flash message' do
        expect(flash[:notice]).to eq('User was created successfully')
      end
      it 'stores the email' do
        expect(user.email).to eq('a@b.com')
      end
      it 'stores the first_name' do
        expect(user.first_name).to eq('John')
      end
      it 'stores the last_name' do
        expect(user.last_name).to eq('Smith')
      end
      it 'stores the role' do
        expect(user.administrator?).to be_truthy
      end
    end
    context 'with invalid data' do
      def post_create
        attrs = FactoryBot.attributes_for(:user, first_name: 'A')
        post(:create, params: { user: attrs })
      end
      it 'does not create a new record' do
        expect do
          post_create
        end.to_not change(User, :count)
      end
      it 're-renders the form with the posted data and title' do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:user).first_name).to eq('A')
        expect(assigns(:title)).to eq('New user')
        expect(assigns(:cancel_path)).to eq(users_path)
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { FactoryBot.create(:default_user, email: 'a@a.com') }
    it 'shows a record for editing' do
      get(:edit, params: { id: user.id })
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:user).id).to eq(user.id)
      expect(assigns(:title)).to eq('Edit user details')
      expect(assigns(:cancel_path)).to eq(user_path(user))
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:edit, params: { id: 99 })
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid data' do
      let(:user) { FactoryBot.create(:default_user, first_name: 'Original') }
      def post_update
        put(:update,
            params: {
              id: user.id,
              user: {
                first_name: 'Changed',
                last_name: user.last_name,
                email: user.email
              }
            })
        user.reload
      end
      before(:each) do
        post_update
      end
      it 'updates the user details' do
        expect(user.first_name).to eq('Changed')
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(user_path(assigns(:user)))
      end
      it 'sets a flash message' do
        expect(flash[:notice]).to eq('User was updated successfully')
      end
    end
    context 'with invalid data' do
      let(:user) { FactoryBot.create(:default_user, first_name: 'Original') }
      def post_update
        put(:update, params: { id: user.id, user: { first_name: '' } })
        user.reload
      end
      before(:each) do
        post_update
      end
      it 'does not update the user details' do
        expect(user.first_name).to eq('Original')
      end
      it 're-renders the form with the posted data' do
        expect(response).to render_template(:edit)
        expect(assigns(:user).first_name).to eq('')
        expect(assigns(:title)).to eq('Edit user details')
        expect(assigns(:cancel_path)).to eq(user_path(user))
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { FactoryBot.create(:default_user) }
    it 'deletes the record' do
      expect do
        delete(:destroy, params: { id: user.id })
      end.to change(User, :count).by(-1)
    end
    it 'redirects to #index' do
      delete(:destroy, params: { id: user.id })
      expect(response).to redirect_to(users_path)
    end
  end
end
