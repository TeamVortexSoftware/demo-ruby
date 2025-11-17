#!/usr/bin/env ruby
# frozen_string_literal: true

# Vortex Ruby SDK Demo Application
#
# This demo provides the same functionality as the Python, Express, Java, and Go demos,
# with identical authentication system, routes, and web interface.

require 'sinatra/base'
require 'json'
require 'openssl'
require 'base64'

# Add the Ruby SDK to load path
$LOAD_PATH.unshift(File.expand_path('../../packages/vortex-ruby-sdk/lib', __dir__))

require 'vortex'
require_relative 'lib/auth'

class VortexRubyDemo < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :static, true
    # Use simple cookie sessions without encryption
    enable :sessions

    # Initialize Vortex client
    set :vortex_api_key, ENV.fetch('VORTEX_API_KEY', 'demo-api-key')
    set :vortex_base_url, ENV['VORTEX_BASE_URL']
  end

  helpers do
    def vortex_client
      @vortex_client ||= begin
        api_key = settings.vortex_api_key
        base_url = settings.vortex_base_url
        Vortex::Client.new(api_key, base_url: base_url)
      end
    end

    def authenticate_vortex_user
      user = get_current_user(session)
      return nil unless user

      admin_scopes = []
      admin_scopes << 'autoJoin' if user.is_auto_join_admin

      {
        id: user.id,
        email: user.email,
        admin_scopes: admin_scopes
      }
    end

    def authorize_vortex_operation(operation, user)
      # For demo purposes, allow all operations if user is authenticated
      # In production, implement proper access control
      user != nil
    end

    def require_authentication
      user = get_current_user(session)
      unless user
        halt 401, json_response({ error: 'Authentication required' })
      end
      user
    end

    def json_response(data)
      content_type :json
      JSON.generate(data)
    end

    def with_error_handling(&block)
      yield
    rescue Vortex::VortexError => e
      logger.error("Vortex error: #{e.message}")
      halt 500, json_response({ error: "Vortex error: #{e.message}" })
    rescue => e
      logger.error("Unexpected error: #{e.message}")
      halt 500, json_response({ error: 'Internal server error' })
    end
  end

  # Root route - serve the HTML interface
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  # Health check endpoint
  get '/health' do
    json_response({
      status: 'OK',
      service: 'vortex-ruby-demo',
      version: Vortex::VERSION,
      timestamp: Time.now.iso8601
    })
  end

  # Authentication endpoints (same as other demos)

  # Login endpoint
  post '/auth/login' do
    request.body.rewind
    data = JSON.parse(request.body.read)

    email = data['email']
    password = data['password']

    unless email && password
      halt 400, json_response({ error: 'Email and password are required' })
    end

    user = authenticate_user(email, password)
    unless user
      halt 401, json_response({ error: 'Invalid credentials' })
    end

    # Create session
    session[:user_id] = user.id
    session[:user_email] = user.email

    json_response({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        is_auto_join_admin: user.is_auto_join_admin
      }
    })
  rescue JSON::ParserError
    halt 400, json_response({ error: 'Invalid JSON' })
  end

  # Logout endpoint
  post '/auth/logout' do
    session.clear
    json_response({ success: true })
  end

  # Get current user
  get '/auth/user' do
    user = get_current_user(session)
    if user
      json_response({
        id: user.id,
        email: user.email,
        is_auto_join_admin: user.is_auto_join_admin
      })
    else
      halt 401, json_response({ error: 'Not authenticated' })
    end
  end

  # Vortex API endpoints (same routes as other SDKs for React provider compatibility)

  # Generate JWT for authenticated user
  # POST /api/vortex/jwt
  post '/api/vortex/jwt' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('JWT', user_data)
        halt 403, json_response({ error: 'Not authorized to generate JWT' })
      end

      jwt = vortex_client.generate_jwt(user: user_data)
      json_response({ jwt: jwt })
    end
  end

  # Get invitations by target
  # GET /api/vortex/invitations?targetType=email&targetValue=user@example.com
  get '/api/vortex/invitations' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('GET_INVITATIONS', user_data)
        halt 403, json_response({ error: 'Not authorized to get invitations' })
      end

      target_type = params['targetType']
      target_value = params['targetValue']

      unless target_type && target_value
        halt 400, json_response({ error: 'Missing targetType or targetValue' })
      end

      invitations = vortex_client.get_invitations_by_target(target_type, target_value)
      json_response({ invitations: invitations })
    end
  end

  # Get specific invitation by ID
  # GET /api/vortex/invitations/:invitation_id
  get '/api/vortex/invitations/:invitation_id' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('GET_INVITATION', user_data)
        halt 403, json_response({ error: 'Not authorized to get invitation' })
      end

      invitation_id = params['invitation_id']
      invitation = vortex_client.get_invitation(invitation_id)
      json_response(invitation)
    end
  end

  # Revoke (delete) invitation
  # DELETE /api/vortex/invitations/:invitation_id
  delete '/api/vortex/invitations/:invitation_id' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('REVOKE_INVITATION', user_data)
        halt 403, json_response({ error: 'Not authorized to revoke invitation' })
      end

      invitation_id = params['invitation_id']
      vortex_client.revoke_invitation(invitation_id)
      json_response({ success: true })
    end
  end

  # Accept invitations
  # POST /api/vortex/invitations/accept
  post '/api/vortex/invitations/accept' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('ACCEPT_INVITATIONS', user_data)
        halt 403, json_response({ error: 'Not authorized to accept invitations' })
      end

      request.body.rewind
      body = request.body.read
      halt 400, json_response({ error: 'Request body is required' }) if body.empty?

      data = JSON.parse(body)
      invitation_ids = data['invitationIds']
      target = data['target']

      unless invitation_ids && target
        halt 400, json_response({ error: 'Missing invitationIds or target' })
      end

      result = vortex_client.accept_invitations(invitation_ids, target)
      json_response(result)
    end
  rescue JSON::ParserError
    halt 400, json_response({ error: 'Invalid JSON in request body' })
  end

  # Get invitations by group
  # GET /api/vortex/invitations/by-group/:group_type/:group_id
  get '/api/vortex/invitations/by-group/:group_type/:group_id' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('GET_GROUP_INVITATIONS', user_data)
        halt 403, json_response({ error: 'Not authorized to get group invitations' })
      end

      group_type = params['group_type']
      group_id = params['group_id']

      invitations = vortex_client.get_invitations_by_group(group_type, group_id)
      json_response({ invitations: invitations })
    end
  end

  # Delete invitations by group
  # DELETE /api/vortex/invitations/by-group/:group_type/:group_id
  delete '/api/vortex/invitations/by-group/:group_type/:group_id' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('DELETE_GROUP_INVITATIONS', user_data)
        halt 403, json_response({ error: 'Not authorized to delete group invitations' })
      end

      group_type = params['group_type']
      group_id = params['group_id']

      vortex_client.delete_invitations_by_group(group_type, group_id)
      json_response({ success: true })
    end
  end

  # Reinvite user
  # POST /api/vortex/invitations/:invitation_id/reinvite
  post '/api/vortex/invitations/:invitation_id/reinvite' do
    with_error_handling do
      user_data = authenticate_vortex_user
      halt 401, json_response({ error: 'Authentication required' }) unless user_data

      unless authorize_vortex_operation('REINVITE', user_data)
        halt 403, json_response({ error: 'Not authorized to reinvite' })
      end

      invitation_id = params['invitation_id']
      result = vortex_client.reinvite(invitation_id)
      json_response(result)
    end
  end

  # Error handlers
  error Vortex::VortexError do
    logger.error("Vortex error: #{env['sinatra.error'].message}")
    content_type :json
    status 500
    JSON.generate({ error: env['sinatra.error'].message })
  end

  error do
    logger.error("Unexpected error: #{env['sinatra.error'].message}")
    content_type :json
    status 500
    JSON.generate({ error: 'Internal server error' })
  end
end

if __FILE__ == $0
  puts "🚀 Demo Ruby server starting..."
  puts "📱 Visit http://localhost:4567 to try the demo"
  puts "🔧 Vortex API routes available at http://localhost:4567/api/vortex"
  puts "📊 Health check: http://localhost:4567/health"
  puts
  puts "Demo users:"
  get_demo_users.each do |user|
    admin_label = user.is_auto_join_admin ? "auto-join admin" : "regular user"
    puts "  - #{user.email} / #{user.password} (#{admin_label})"
  end

  VortexRubyDemo.run!
end