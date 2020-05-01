module Api
  class TasksController < ActionController::API
    before_action :authenticate_request

    def create
      begin
        task = BackgroundTask.create!(task_type: params[:task_type])
        task.schedule_task
        render json: task, status: :created
      rescue StandardError => error
        render json: { error: error }, status: :bad_request
      end
    end

    private

    def authenticate_request
      match = params.include?(:secret) && params[:secret] == ENV['FOOTFALL_API_SECRET']
      render json: {}, status: :unauthorized unless match
    end
  end
end