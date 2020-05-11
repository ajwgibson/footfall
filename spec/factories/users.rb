FactoryBot.define do
  factory :user do
  end

  factory :default_user, parent: :user do
    email                 { Faker::Internet.email }
    password              { 'Aa34567890' }
    password_confirmation { 'Aa34567890' }
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    role                  { :standard_user }
  end

  factory :administrator, parent: :default_user do
    role { :administrator }
  end
end
