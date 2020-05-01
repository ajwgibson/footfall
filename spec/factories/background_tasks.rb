FactoryBot.define do
  factory :background_task do
  end

  factory :default_background_task, parent: :background_task do
    task_type { :retrieve_footfall_data }
    status { :scheduled }
    outcome { :unknown }
  end

  factory :running_background_task, parent: :default_background_task do
    status { :running }
  end

  factory :finished_background_task, parent: :default_background_task do
    status { :finished }
  end
end
