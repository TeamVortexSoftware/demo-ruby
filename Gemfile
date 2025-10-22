# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.0.0'

# Web framework
gem 'sinatra', '~> 3.0'

# Web server
gem 'puma', '~> 6.0'

# JSON handling
gem 'json', '~> 2.6'

# HTTP client (required by Vortex SDK)
gem 'faraday', '~> 2.0'
gem 'faraday-net_http', '~> 3.0'

# Rack (required by Vortex SDK)
gem 'rack', '>= 2.0'

# Development and testing
group :development do
  gem 'rerun', '~> 0.14'
end

# For development, we'll use the local Vortex SDK
# In production, you'd use: gem 'vortex-ruby-sdk'