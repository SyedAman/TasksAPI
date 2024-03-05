FactoryBot.define do
  factory :task do
    title { "MyString" }
    description { "MyText" }
    due_date { "2024-03-05 16:20:33" }
    status { 1 }
    priority { 1 }
    completed_date { "2024-03-05 16:20:33" }
  end
end
