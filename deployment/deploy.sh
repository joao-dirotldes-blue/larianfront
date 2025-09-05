#!/bin/bash

# Larian App Deployment Script
# This script deploys both agency and seller frontends using Docker Compose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Load environment variables
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
    print_message "✅ Environment variables loaded" "$GREEN"
else
    print_message "⚠️  .env.production file not found. Using default values." "$YELLOW"
fi

# Check prerequisites
print_message "Checking prerequisites..." "$YELLOW"

if ! command_exists docker; then
    print_message "❌ Docker is not installed. Please install Docker first." "$RED"
    exit 1
fi

if ! command_exists docker-compose; then
    # Try docker compose (newer version)
    if ! docker compose version >/dev/null 2>&1; then
        print_message "❌ Docker Compose is not installed. Please install Docker Compose." "$RED"
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

print_message "✅ All prerequisites are installed" "$GREEN"

# Function to deploy
deploy() {
    print_message "\n🚀 Starting deployment..." "$YELLOW"
    
    # Stop existing containers
    print_message "Stopping existing containers..." "$YELLOW"
    $DOCKER_COMPOSE down --remove-orphans || true
    
    # Build and start containers
    print_message "Building and starting containers..." "$YELLOW"
    $DOCKER_COMPOSE --env-file .env.production up -d --build
    
    # Wait for services to be healthy
    print_message "Waiting for services to become healthy..." "$YELLOW"
    
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if $DOCKER_COMPOSE ps | grep -q "healthy"; then
            print_message "✅ Services are healthy!" "$GREEN"
            break
        else
            echo -n "."
            sleep 2
            attempt=$((attempt + 1))
        fi
    done
    
    if [ $attempt -eq $max_attempts ]; then
        print_message "\n⚠️  Services did not become healthy in time. Checking logs..." "$YELLOW"
        $DOCKER_COMPOSE logs --tail=50
    fi
    
    # Show running services
    print_message "\n📊 Running services:" "$GREEN"
    $DOCKER_COMPOSE ps
    
    print_message "\n✅ Deployment completed successfully!" "$GREEN"
    print_message "\nAccess your applications at:" "$GREEN"
    print_message "  - Agency: http://${DOMAIN_NAME}/agency" "$GREEN"
    print_message "  - Seller: http://${DOMAIN_NAME}/seller" "$GREEN"
}

# Function to setup SSL with Let's Encrypt
setup_ssl() {
    print_message "\n🔒 Setting up SSL certificates..." "$YELLOW"
    
    read -p "Enter your email for Let's Encrypt notifications: " CERTBOT_EMAIL
    
    # First, get certificates
    docker run -it --rm \
        -v ./ssl:/etc/letsencrypt \
        -v ./certbot-www:/var/www/certbot \
        certbot/certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email ${CERTBOT_EMAIL} \
        --agree-tos \
        --no-eff-email \
        -d ${DOMAIN_NAME} \
        -d ${WWW_DOMAIN_NAME}
    
    if [ $? -eq 0 ]; then
        print_message "✅ SSL certificates obtained successfully!" "$GREEN"
        print_message "Uncomment the HTTPS server block in nginx.conf and redeploy." "$YELLOW"
        
        # Enable certbot service
        $DOCKER_COMPOSE --profile ssl up -d certbot
    else
        print_message "❌ Failed to obtain SSL certificates." "$RED"
    fi
}

# Function to show logs
show_logs() {
    service=$1
    if [ -z "$service" ]; then
        $DOCKER_COMPOSE logs -f --tail=100
    else
        $DOCKER_COMPOSE logs -f --tail=100 $service
    fi
}

# Function to restart services
restart() {
    print_message "Restarting services..." "$YELLOW"
    $DOCKER_COMPOSE restart
    print_message "✅ Services restarted" "$GREEN"
}

# Function to stop services
stop() {
    print_message "Stopping services..." "$YELLOW"
    $DOCKER_COMPOSE down
    print_message "✅ Services stopped" "$GREEN"
}

# Function to pull latest code
update_code() {
    print_message "Updating code from repositories..." "$YELLOW"
    
    # Update agency front
    if [ -d "../gufly-agency-front" ]; then
        cd ../gufly-agency-front
        git pull origin main
        cd ../deployment
        print_message "✅ Agency front updated" "$GREEN"
    fi
    
    # Update seller front
    if [ -d "../gufly-seller-front" ]; then
        cd ../gufly-seller-front
        git pull origin main
        cd ../deployment
        print_message "✅ Seller front updated" "$GREEN"
    fi
}

# Function to clean up
cleanup() {
    print_message "Cleaning up..." "$YELLOW"
    docker system prune -af --volumes
    print_message "✅ Cleanup completed" "$GREEN"
}

# Main menu
case "$1" in
    deploy)
        deploy
        ;;
    ssl)
        setup_ssl
        ;;
    logs)
        show_logs $2
        ;;
    restart)
        restart
        ;;
    stop)
        stop
        ;;
    update)
        update_code
        deploy
        ;;
    cleanup)
        cleanup
        ;;
    *)
        print_message "Larian App Deployment Script" "$GREEN"
        print_message "============================\n" "$GREEN"
        echo "Usage: $0 {deploy|ssl|logs|restart|stop|update|cleanup}"
        echo ""
        echo "Commands:"
        echo "  deploy    - Build and deploy all services"
        echo "  ssl       - Setup SSL certificates with Let's Encrypt"
        echo "  logs      - Show logs (optionally specify service: logs nginx)"
        echo "  restart   - Restart all services"
        echo "  stop      - Stop all services"
        echo "  update    - Pull latest code and redeploy"
        echo "  cleanup   - Clean up Docker resources"
        echo ""
        echo "Examples:"
        echo "  $0 deploy         # Deploy all services"
        echo "  $0 logs nginx     # Show nginx logs"
        echo "  $0 ssl           # Setup SSL certificates"
        exit 1
        ;;
esac