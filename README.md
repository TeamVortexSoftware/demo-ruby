# Vortex Ruby SDK Demo

A complete demo application showcasing the Vortex Ruby SDK with Sinatra, providing the same functionality as the Python, Express, Java, and Go demos.

## Features

- **Same Authentication System**: Identical demo users and login flow as other demos
- **Complete API Coverage**: All Vortex SDK endpoints with same route structure
- **Interactive Web Interface**: HTML interface for testing all functionality
- **Ruby Branding**: Ruby gem-themed design with red color scheme
- **Session Management**: Cookie-based sessions for user authentication
- **Error Handling**: Comprehensive error handling and user feedback

## Prerequisites

- **Ruby 3.0+**: Required for modern syntax and features
- **Bundler**: For dependency management

## Quick Start

1. **Start the server**:
   ```bash
   ./run.sh
   ```

2. **Open your browser**:
   ```
   http://localhost:4567
   ```

3. **Login with demo credentials**:
   - **Admin**: `admin@example.com` / `password123`
   - **User**: `user@example.com` / `userpass`

## API Endpoints

The Ruby demo provides identical API endpoints to other SDKs:

### Authentication
- `POST /auth/login` - Login with email/password
- `POST /auth/logout` - Logout current user
- `GET /auth/user` - Get current user info

### Vortex API (Same as other SDKs)
- `POST /api/vortex/jwt` - Generate JWT token
- `GET /api/vortex/invitations?targetType=email&targetValue=user@example.com` - Get invitations by target
- `GET /api/vortex/invitations/:id` - Get specific invitation
- `DELETE /api/vortex/invitations/:id` - Revoke invitation
- `POST /api/vortex/invitations/accept` - Accept invitations
- `GET /api/vortex/invitations/by-group/:type/:id` - Get group invitations
- `DELETE /api/vortex/invitations/by-group/:type/:id` - Delete group invitations
- `POST /api/vortex/invitations/:id/reinvite` - Reinvite user

### Utility
- `GET /health` - Health check endpoint
- `GET /` - Web interface

## File Structure

```
demo-ruby/
├── app.rb              # Main Sinatra application
├── lib/
│   └── auth.rb         # Authentication system (same users as other demos)
├── public/
│   └── index.html      # Interactive web interface
├── Gemfile             # Ruby dependencies
├── run.sh              # Startup script
└── README.md           # This file
```

## Demo Users

Same users as other demos for consistency:

| Email | Password | Role | Groups |
|-------|----------|------|--------|
| `admin@example.com` | `password123` | admin | Administrators, All Users |
| `user@example.com` | `userpass` | user | Regular Users, All Users |

## Configuration

Environment variables:

- `VORTEX_API_KEY`: Your Vortex API key (defaults to "demo-api-key")
- `VORTEX_BASE_URL`: Custom Vortex API base URL (optional)
- `SESSION_SECRET`: Session encryption key (defaults to demo key)

## Development

### Manual Setup

If you prefer not to use the run script:

```bash
# Install dependencies
bundle install

# Set environment variables
export VORTEX_API_KEY="your-api-key"
export SESSION_SECRET="your-secret-key"

# Start server
ruby app.rb
```

### Dependencies

The demo uses minimal dependencies:

- **Sinatra**: Lightweight web framework
- **JSON**: JSON parsing and generation (built-in)
- **Rerun**: Auto-restart during development (optional)

### Local SDK Development

The demo uses the local Vortex Ruby SDK from `../../packages/vortex-ruby-sdk/lib`. In production, you would install the published gem:

```ruby
gem 'vortex-ruby-sdk'
```

## Testing the Demo

### 1. Authentication Flow
1. Open http://localhost:4567
2. Login with demo credentials
3. Verify user info displays correctly

### 2. JWT Generation
1. Click "Generate JWT"
2. Verify JWT token is returned
3. Check that JWT contains user data

### 3. Invitation Management
1. Test "Get Invitations by Target" with different email addresses
2. Test "Get Invitations by Group" with different group types
3. Test "Accept Invitations" with sample invitation IDs

### 4. API Compatibility
The Ruby demo provides identical functionality to other SDK demos, ensuring React provider compatibility and consistent behavior across all platforms.

## Comparison with Other Demos

| Feature | Ruby | Python | Express | Java | Go |
|---------|------|--------|---------|------|-----|
| Framework | Sinatra | FastAPI | Express | Spring Boot | Gin |
| Port | 4567 | 8000 | 3000 | 8080 | 8080 |
| Authentication | ✅ | ✅ | ✅ | ✅ | ✅ |
| Same Routes | ✅ | ✅ | ✅ | ✅ | ✅ |
| Web Interface | ✅ | ✅ | ✅ | ✅ | ✅ |
| Same Users | ✅ | ✅ | ✅ | ✅ | ✅ |

## Troubleshooting

### Ruby Version Issues
```bash
# Check Ruby version
ruby -v

# Ensure Ruby 3.0+
ruby -e "puts RUBY_VERSION"
```

### Dependency Issues
```bash
# Update bundler
gem update bundler

# Clean install
bundle install --clean --force
```

### Port Conflicts
If port 4567 is in use, modify the port in `app.rb`:

```ruby
VortexRubyDemo.run!(port: 4568)
```

## Production Deployment

For production use:

1. **Use a production web server** (Puma, Unicorn)
2. **Set proper environment variables**
3. **Use the published gem**: `gem 'vortex-ruby-sdk'`
4. **Implement proper authentication**
5. **Add logging and monitoring**

Example with Puma:

```ruby
# config.ru
require './app'
run VortexRubyDemo
```

```bash
# Start with Puma
bundle exec puma config.ru
```

This demo showcases the complete Vortex Ruby SDK functionality with the same user experience as all other SDK demos!