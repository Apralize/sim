# ==========================================
# SIM AI STUDIO - Makefile
# ==========================================
# Commands to manage the application
# Usage: make <command>
# ==========================================

.PHONY: help setup secrets env up down restart logs logs-app logs-db logs-realtime ps health clean backup restore build pull update install check-docker

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

##@ General

help: ## Show this help message
	@echo "$(BLUE)╔══════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║$(NC)     SIM AI STUDIO - Available Commands     $(BLUE)║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(GREEN)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

check-docker: ## Verify Docker is installed and running
	@echo "$(BLUE)Checking Docker installation...$(NC)"
	@which docker > /dev/null 2>&1 || (echo "$(RED)Error: Docker is not installed$(NC)" && exit 1)
	@docker info > /dev/null 2>&1 || (echo "$(RED)Error: Docker daemon is not running$(NC)" && exit 1)
	@which docker-compose > /dev/null 2>&1 || docker compose version > /dev/null 2>&1 || (echo "$(RED)Error: Docker Compose is not installed$(NC)" && exit 1)
	@echo "$(GREEN)✓ Docker is ready$(NC)"

##@ Setup & Configuration

setup: check-docker ## Complete setup (check dependencies + generate secrets + create .env)
	@echo "$(BLUE)Setting up SIM AI Studio...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env file from template...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env file created$(NC)"; \
		echo "$(YELLOW)⚠️  Remember to configure your .env file with proper values!$(NC)"; \
		echo "$(YELLOW)   Run 'make secrets' to generate secure secrets$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists$(NC)"; \
	fi
	@chmod +x scripts/*.sh 2>/dev/null || true
	@echo "$(GREEN)✓ Setup complete$(NC)"
	@echo ""
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Run: $(GREEN)make secrets$(NC) to generate secure secrets"
	@echo "  2. Edit: $(GREEN).env$(NC) file with your configuration"
	@echo "  3. Run: $(GREEN)make up$(NC) to start the application"

secrets: ## Generate secure secrets for .env
	@echo "$(BLUE)Generating secure secrets...$(NC)"
	@echo ""
	@./scripts/generate-secrets.sh
	@echo ""

env: ## Create .env file from template
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env file created from template$(NC)"; \
		echo "$(YELLOW)⚠️  Please edit .env with your configuration$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists. Use 'make env-reset' to recreate$(NC)"; \
	fi

env-reset: ## Reset .env file (backup current one)
	@if [ -f .env ]; then \
		cp .env .env.backup.$(shell date +%Y%m%d_%H%M%S); \
		echo "$(GREEN)✓ Current .env backed up$(NC)"; \
	fi
	@cp .env.example .env
	@echo "$(GREEN)✓ .env file reset from template$(NC)"

##@ Docker Services

up: check-docker ## Start all services
	@echo "$(BLUE)Starting SIM AI Studio...$(NC)"
	@docker compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@echo ""
	@echo "$(BLUE)Waiting for services to be healthy...$(NC)"
	@sleep 5
	@make health
	@echo ""
	@echo "$(GREEN)✓ Application is ready!$(NC)"
	@echo "$(BLUE)Access at: http://localhost:3000$(NC)"

down: ## Stop all services
	@echo "$(BLUE)Stopping SIM AI Studio...$(NC)"
	@docker compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart: ## Restart all services
	@echo "$(BLUE)Restarting SIM AI Studio...$(NC)"
	@docker compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

stop: ## Stop services (alias for down)
	@make down

start: ## Start services (alias for up)
	@make up

##@ Logs & Monitoring

logs: ## Show logs from all services
	@docker compose logs -f

logs-app: ## Show logs from main application
	@docker compose logs -f simstudio

logs-db: ## Show logs from database
	@docker compose logs -f db

logs-realtime: ## Show logs from realtime server
	@docker compose logs -f realtime

ps: ## Show running containers
	@docker compose ps

health: ## Check health status of all services
	@./scripts/health-check.sh

stats: ## Show resource usage statistics
	@docker stats --no-stream simstudio-app simstudio-db simstudio-realtime 2>/dev/null || echo "$(YELLOW)Services not running$(NC)"

##@ Database

db-shell: ## Access PostgreSQL shell
	@docker exec -it simstudio-db psql -U postgres -d simstudio

db-backup: ## Create database backup
	@mkdir -p backups
	@docker exec simstudio-db pg_dump -U postgres simstudio > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Database backup created in backups/$(NC)"

db-restore: ## Restore database from backup (Usage: make db-restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Please specify backup file$(NC)"; \
		echo "Usage: make db-restore FILE=backups/backup_20240116.sql"; \
		exit 1; \
	fi
	@docker exec -i simstudio-db psql -U postgres simstudio < $(FILE)
	@echo "$(GREEN)✓ Database restored from $(FILE)$(NC)"

db-migrations: ## Run database migrations manually
	@docker compose run --rm migrations bun run db:migrate
	@echo "$(GREEN)✓ Migrations completed$(NC)"

db-size: ## Show database size
	@docker exec simstudio-db psql -U postgres -d simstudio -c "SELECT pg_size_pretty(pg_database_size('simstudio')) as size;"

##@ Maintenance

clean: ## Remove stopped containers and unused resources
	@echo "$(BLUE)Cleaning up Docker resources...$(NC)"
	@docker compose down
	@docker system prune -f
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

clean-all: ## Remove all containers, volumes, and images (DESTRUCTIVE)
	@echo "$(RED)⚠️  WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		docker system prune -af --volumes; \
		echo "$(GREEN)✓ All resources removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

pull: ## Pull latest Docker images
	@echo "$(BLUE)Pulling latest images...$(NC)"
	@docker compose pull
	@echo "$(GREEN)✓ Images updated$(NC)"

update: pull ## Update and restart services with new images
	@echo "$(BLUE)Updating SIM AI Studio...$(NC)"
	@docker compose up -d --force-recreate
	@echo "$(GREEN)✓ Services updated and restarted$(NC)"

##@ Development

dev: ## Start in development mode (using source code)
	@if [ ! -d "node_modules" ]; then \
		echo "$(YELLOW)Installing dependencies...$(NC)"; \
		bun install; \
	fi
	@echo "$(BLUE)Starting development server...$(NC)"
	@bun run dev:full

install: ## Install dependencies locally
	@echo "$(BLUE)Installing dependencies...$(NC)"
	@bun install
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

build: ## Build Docker images locally
	@echo "$(BLUE)Building Docker images...$(NC)"
	@docker compose -f docker-compose.yml build
	@echo "$(GREEN)✓ Images built$(NC)"

##@ Ollama (Local AI Models)

ollama-up: ## Start with Ollama support
	@echo "$(BLUE)Starting SIM AI Studio with Ollama...$(NC)"
	@docker compose -f docker-compose.ollama.yml --profile setup up -d
	@echo "$(GREEN)✓ Services started with Ollama$(NC)"

ollama-pull: ## Pull additional Ollama models
	@if [ -z "$(MODEL)" ]; then \
		echo "$(YELLOW)Available models: llama3.1:8b, codellama, mistral, gemma3:4b$(NC)"; \
		echo "Usage: make ollama-pull MODEL=llama3.1:8b"; \
		exit 1; \
	fi
	@docker compose -f docker-compose.ollama.yml exec ollama ollama pull $(MODEL)

ollama-list: ## List installed Ollama models
	@docker compose -f docker-compose.ollama.yml exec ollama ollama list

##@ Information

version: ## Show version information
	@echo "$(BLUE)SIM AI Studio v0.5.60$(NC)"
	@echo ""
	@echo "Docker version:"
	@docker --version
	@echo ""
	@echo "Docker Compose version:"
	@docker compose version || docker-compose --version

docs: ## Open documentation
	@echo "$(BLUE)Opening documentation...$(NC)"
	@xdg-open README.es.md 2>/dev/null || open README.es.md 2>/dev/null || echo "$(YELLOW)Please open README.es.md manually$(NC)"

status: ## Show complete status information
	@echo "$(BLUE)╔══════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║$(NC)          SIM AI Studio Status              $(BLUE)║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════╝$(NC)"
	@echo ""
	@make ps
	@echo ""
	@make health
	@echo ""
	@make stats

##@ Quick Actions

quick-start: setup up ## Quick start (setup + start services)
	@echo "$(GREEN)✓ Quick start completed!$(NC)"

reset: down clean up ## Reset services (stop, clean, restart)
	@echo "$(GREEN)✓ Services reset$(NC)"
