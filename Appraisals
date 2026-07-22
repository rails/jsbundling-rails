if RUBY_VERSION <= "3.2"
  appraise "rails_6_1" do
    gem "rails", "~> 6.1.0"
    gem 'concurrent-ruby', '<= 1.3.4'
  end
end

if RUBY_VERSION <= "3.3"
  appraise "rails_7_0" do
    gem "rails", "~> 7.0.0"
    gem 'concurrent-ruby', '<= 1.3.4'
    gem "propshaft"
  end
end

appraise "rails_7_1" do
  gem "rails", "~> 7.1.0"
  gem "propshaft"
end

appraise "rails_7_2" do
  gem "rails", "~> 7.2.0"
  gem "propshaft"
end

if RUBY_VERSION >= "3.2"
  appraise "rails_8_0" do
    gem "rails", "~> 8.0.0"
    gem "propshaft"
  end

  appraise "rails_8_1" do
    gem "rails", "~> 8.1.0"
    gem "propshaft"
  end
end

if RUBY_VERSION >= "3.3"
  appraise "rails_main" do
    gem "rails", github: "rails/rails", branch: "main"
    gem "propshaft"
  end
end
