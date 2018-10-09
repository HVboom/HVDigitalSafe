FactoryBot.define do
  factory :secure_data_storage do
    token { "MyToken" }
    document { "MyDocument" }
  end
end
