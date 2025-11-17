# frozen_string_literal: true

# Authentication system for Ruby demo
#
# Provides the same demo users and authentication logic as other demos
# to ensure consistent behavior across all SDK demonstrations.

# Demo user class (simplified)
class DemoUser
  attr_reader :id, :email, :password, :is_auto_join_admin

  def initialize(id, email, password, is_auto_join_admin)
    @id = id
    @email = email
    @password = password
    @is_auto_join_admin = is_auto_join_admin
  end
end

# Demo users (simplified structure)
def get_demo_users
  [
    DemoUser.new(
      'admin-user-123',
      'admin@example.com',
      'password123',
      true  # Auto-join admin
    ),
    DemoUser.new(
      'user-user-456',
      'user@example.com',
      'userpass',
      false  # Regular user
    )
  ]
end

# Authenticate user with email and password
#
# @param email [String] User email address
# @param password [String] User password
# @return [DemoUser, nil] User object if authentication succeeds, nil otherwise
def authenticate_user(email, password)
  get_demo_users.find { |user| user.email == email && user.password == password }
end

# Get current user from session
#
# @param session [Hash] Session data
# @return [DemoUser, nil] Current user if session is valid, nil otherwise
def get_current_user(session)
  return nil unless session[:user_id] && session[:user_email]

  get_demo_users.find { |user|
    user.id == session[:user_id] && user.email == session[:user_email]
  }
end

# Verify if user is an auto-join admin
#
# @param user [DemoUser] User to check
# @return [Boolean] True if user is auto-join admin
def user_is_admin?(user)
  return false unless user
  user.is_auto_join_admin
end