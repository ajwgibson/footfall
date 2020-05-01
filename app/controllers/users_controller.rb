# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Users'
    @users = User.filter(@filter).order(:first_name, :last_name)
    @users = @users.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to users_path
  end

  def show
    @title = 'User details'
  end

  def new
    @user = User.new
    @title = 'New user'
    @cancel_path = users_path
    render :edit
  end

  def create
    @user = User.new user_params
    if @user.save
      redirect_to(user_path(@user), notice: 'User was created successfully')
    else
      @title       = 'New user'
      @cancel_path = users_path
      render :edit
    end
  end

  def edit
    @title = 'Edit user details'
    @cancel_path = user_path(@user)
  end

  def update
    if @user.update_without_password user_params
      redirect_to user_path(@user), notice: 'User was updated successfully'
    else
      @title       = 'Edit user details'
      @cancel_path = user_path(@user)
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User was deleted'
  end

  private

  def user_params
    params
      .require(:user)
      .permit(
        :email,
        :first_name,
        :last_name,
        :password,
        :password_confirmation
      )
  end

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_name,
        :with_email
      ).to_h
    filter = session[:filter_users].symbolize_keys! if filter.empty? && session.key?(:filter_users)
    filter[:order_by] = 'first_name, last_name' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_users] = filter unless filter.nil?
    session.delete(:filter_users) if filter.nil?
  end
end
