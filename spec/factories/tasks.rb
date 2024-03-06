FactoryBot.define do
  factory :task do
    association :user
    title { "Sample Task" }
    description { "MyText" }
    due_date { 1.week.from_now }
    status { "in_progress" }
    priority { "medium" }
    completed_date { nil }
  end
end
