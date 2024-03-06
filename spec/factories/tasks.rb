FactoryBot.define do
  factory :task do
    title { "MyString" }
    description { "MyText" }
    due_date { Time.now + 1.week }
    status { :in_progress }
    priority { :medium }
    completed_date { nil }
  end
end
