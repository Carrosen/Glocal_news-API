FactoryBot.define do
  factory :review do
    score { 1 }
    comment { "MyString" }
    association :article
    association :user
  end
end
