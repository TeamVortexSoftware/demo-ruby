#!/bin/bash

# Vortex Ruby Demo Runner
# This script starts the Ruby demo server with the same functionality as other demos

set -e

echo "🚀 Starting Vortex Ruby Demo..."

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is required but not installed."
    echo "   Install Ruby 3.0+ and try again."
    echo "   Visit: https://ruby-lang.org/en/downloads/"
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
REQUIRED_VERSION="3.0.0"

if ! ruby -e "exit Gem::Version.new('$RUBY_VERSION') >= Gem::Version.new('$REQUIRED_VERSION')"; then
    echo "❌ Ruby 3.0.0 or higher is required. Current version: $RUBY_VERSION"
    exit 1
fi

echo "✅ Ruby $RUBY_VERSION detected"

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing Bundler..."
    gem install bundler
fi

# Install dependencies
echo "📦 Installing dependencies..."
bundle install

# Set default environment variables
export VORTEX_API_KEY="${VORTEX_API_KEY:-demo-api-key}"
export SESSION_SECRET="${SESSION_SECRET:-demo-session-secret-key-32-bytes}"

# Start the server
echo "🌟 Starting server on port 4567..."
echo "📱 Visit http://localhost:4567 to try the demo"
echo "🔧 Vortex API routes available at http://localhost:4567/api/vortex"
echo "📊 Health check: http://localhost:4567/health"
echo ""
echo "Demo users:"
echo "  - admin@example.com / password123 (admin role)"
echo "  - user@example.com / userpass (user role)"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Run the server with bundler
bundle exec ruby app.rb