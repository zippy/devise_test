source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem "cancan"
gem 'warden'
gem 'will_paginate', "3.0.pre2"
#gem 'devise', :git => 'git://github.com/plataformatec/devise.git', :ref=>'b942520dc4f'#, :tag=>'v1.2.rc'#,#'1.1.5'
gem 'devise', :path => '/Users/eric/Coding/devise/'
gem 'pg'
gem "hoptoad_notifier", "~> 2.4"
gem 'oauth2'
gem 'warden_oauth'

group :test,:development,:cucumber do
  gem 'ruby-debug'
  gem "rspec-rails", "~> 2.4"
  gem 'sqlite3-ruby'
end

group :cucumber do
	gem 'syntax'
#	gem 'akephalos'
	gem 'culerity'
	gem 'celerity', :require => nil # JRuby only. Make it available but don't require it in any environment.
  gem 'launchy'
  gem 'sqlite3-ruby'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'capybara', '0.4.1.rc'
  gem 'xpath', '0.1.3'
end

