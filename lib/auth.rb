# frozen_string_literal: true

# Authentication system for Ruby demo
#
# Provides the same demo users and authentication logic as other demos
# to ensure consistent behavior across all SDK demonstrations.

# Demo user class
class DemoUser
  attr_reader :id, :email, :password, :role, :groups

  def initialize(id, email, password, role, groups = [])
    @id = id
    @email = email
    @password = password
    @role = role
    @groups = groups
  end
end

# Demo group class
class UserGroup
  attr_reader :id, :type, :name

  def initialize(id, type, name)
    @id = id
    @type = type
    @name = name
  end

  def to_h
    {
      id: @id,
      type: @type,
      name: @name
    }
  end
end

# Demo users (same as other demos)
def get_demo_users
  admin_groups = [
    UserGroup.new('admin-group', 'role', 'Administrators'),
    UserGroup.new('all-users', 'organization', 'All Users')
  ]

  user_groups = [
    UserGroup.new('user-group', 'role', 'Regular Users'),
    UserGroup.new('all-users', 'organization', 'All Users')
  ]

  [
    DemoUser.new(
      'admin-user-123',
      'admin@example.com',
      'password123',
      'admin',
      admin_groups
    ),
    DemoUser.new(
      'user-user-456',
      'user@example.com',
      'userpass',
      'user',
      user_groups
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

# Verify if user has required role
#
# @param user [DemoUser] User to check
# @param required_role [String] Required role (admin, user)
# @return [Boolean] True if user has required role
def user_has_role?(user, required_role)
  return false unless user

  case required_role
  when 'admin'
    user.role == 'admin'
  when 'user'
    ['admin', 'user'].include?(user.role)
  else
    false
  end
end