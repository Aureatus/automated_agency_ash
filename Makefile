.PHONY: setup setup-db setup-frontend setup-ssl dev check-deps setup-env check-system-deps

SETUP_COMPLETE_FILE := .setup-complete

check-system-deps: ## Check for required system dependencies
	@echo "Checking system dependencies..."
	@missing_deps=0; \
	if ! command -v docker >/dev/null 2>&1; then \
		echo "- Docker is not installed. Please install Docker Desktop:"; \
		echo "  Visit https://www.docker.com/products/docker-desktop/"; \
		missing_deps=1; \
	elif ! docker info >/dev/null 2>&1; then \
		echo "- Docker daemon is not running. Please start Docker Desktop."; \
		missing_deps=1; \
	fi; \
	if ! command -v tmux >/dev/null 2>&1; then \
		echo "- tmux is not installed. Please install tmux:"; \
		echo "  Mac: brew install tmux"; \
		echo "  Ubuntu/Debian: sudo apt-get install tmux"; \
		echo "  Arch: sudo pacman -S tmux"; \
		echo "  Fedora: sudo dnf install tmux"; \
		missing_deps=1; \
	fi; \
	if ! command -v node >/dev/null 2>&1; then \
		echo "- Node.js is not installed. Please install Node.js:"; \
		echo "  Visit https://nodejs.org/"; \
		echo "  Recommended version: 18 or later"; \
		missing_deps=1; \
	fi; \
	if ! command -v elixir >/dev/null 2>&1; then \
		echo "- Elixir is not installed. Please install Elixir:"; \
		echo "  Visit https://elixir-lang.org/install.html"; \
		echo "  Recommended version: 1.14 or later"; \
		missing_deps=1; \
	fi; \
	if [ $$missing_deps -eq 1 ]; then \
		echo "\nPlease install the missing dependencies and try again."; \
		exit 1; \
	fi
setup: check-system-deps setup-env setup-db setup-frontend setup-chrome ## Setup complete development environment
	@touch $(SETUP_COMPLETE_FILE)

setup-env: ## Setup environment variables
	@echo "Setting up environment variables..."
	@if [ ! -f .env ]; then \
		cp .env.template .env; \
	fi
	@secret_key=$$(mix phx.gen.secret); \
	sed -i.bak "s|^SECRET_KEY_BASE=.*$$|SECRET_KEY_BASE=$$secret_key|" .env && rm .env.bak
	@if [ ! -f frontend/.env.local ]; then \
		cp frontend/.env.local.template frontend/.env.local; \
		echo "frontend/.env.local created"; \
	fi
	@current_key=$$(grep "^OPENAI_API_KEY=" .env | cut -d= -f2); \
	if [ -z "$$current_key" ]; then \
		read -p "Please enter your OpenAI API key: " api_key; \
		if [ -z "$$api_key" ]; then \
			echo "OpenAI API key is required. Setup cannot continue."; \
			exit 1; \
		fi; \
		sed -i.bak "s|^OPENAI_API_KEY=.*$$|OPENAI_API_KEY=$$api_key|" .env && rm .env.bak; \
	fi

setup-db: ## Setup database and run migrations
	@echo "Setting up database..."
	mix deps.get
	mix ecto.create
	mix ecto.migrate
	@echo "Database setup complete"

setup-frontend: ## Install frontend dependencies
	@echo "Setting up frontend..."
	cd frontend && npm install
	@echo "Frontend setup complete"

setup-chrome: ## Setup ChromeDriver dependencies
	@echo "Setting up ChromeDriver..."
	mix fetch_chrome_deps
	@echo "ChromeDriver setup complete"

check-deps:
	@if [ ! -f $(SETUP_COMPLETE_FILE) ]; then \
		echo "First time setup required. Running setup..."; \
		$(MAKE) setup; \
	fi
	@if ! grep -q "^OPENAI_API_KEY=." .env; then \
		echo "OpenAI API key is missing. Please add OPENAI_API_KEY=your_key_here to your .env file"; \
		exit 1; \
	fi

dev: check-deps ## Start development environment with tmux
	./scripts/dev.sh

help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help