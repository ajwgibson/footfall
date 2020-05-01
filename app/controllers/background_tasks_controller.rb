# frozen_string_literal: true

class BackgroundTasksController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Background tasks'
    @background_tasks = BackgroundTask.filter(@filter)
    @background_tasks = @background_tasks.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to background_tasks_path
  end

  def show
    @title = 'Background task details'
  end

  def new
    @background_task = BackgroundTask.new
    @title = 'New background task'
    @cancel_path = background_tasks_path
    render :edit
  end

  def create
    @background_task = BackgroundTask.new background_task_params
    if @background_task.save
      @background_task.schedule_task
      redirect_to(
        background_task_path(@background_task),
        notice: 'Background task was created successfully'
      )
    else
      @title       = 'New background task'
      @cancel_path = background_tasks_path
      render :edit
    end
  end

  def destroy
    @background_task.destroy
    redirect_to background_tasks_path, notice: 'Background task was deleted'
  end

  private

  def background_task_params
    params
      .require(:background_task)
      .permit(
        :task_type
      )
  end

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_task_type,
        :with_status,
        :with_outcome
      ).to_h
    if filter.empty? && session.key?(:filter_background_tasks)
      filter = session[:filter_background_tasks].symbolize_keys!
    end
    filter[:order_by] = 'id desc' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_background_tasks] = filter unless filter.nil?
    session.delete(:filter_background_tasks) if filter.nil?
  end
end
