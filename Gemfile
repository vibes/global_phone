# frozen_string_literal: true
# A sample Gemfile
source "https://rubygems.org"

gemspec :name => 'global_phone'

install_if(lambda { RUBY_VERSION > '1.9' }) do
  gem 'travis', :group => :tools
  gem 'test-unit', '< 2'
end

group :development do
  if RUBY_VERSION < '1.9'
    gem "rake", "< 11"
  else
    gem "rake"
  end
  platform :mri_18 do
    gem "json", "< 2"
  end
  gem "nokogiri", "~> 1.5"
end
