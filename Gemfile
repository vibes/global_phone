# frozen_string_literal: true
# A sample Gemfile
source "https://rubygems.org"

gemspec :name => 'global_phone'

group :tools do
  install_if(lambda { RUBY_VERSION > '1.9' }) do
    gem 'travis'
  end
end

group :development do
  platform :mri_18 do
    gem "rake", "< 11"
    gem "json", "< 2"
  end
end
