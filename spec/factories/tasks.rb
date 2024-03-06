FactoryBot.define do
  factory :task do
    association :user # This assumes you have a user factory
    title { "MyString" }
    description { "MyText" }
    due_date { 1.week.from_now }
    status { "in_progress" }
    priority { "medium" }
    completed_date { nil }
  end
end
