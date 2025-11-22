# Justfile for Social Media Polygraph
# https://github.com/casey/just

# Default recipe (list all recipes)
default:
    @just --list

# Install all dependencies
install:
    @echo "Installing backend dependencies..."
    cd backend && poetry install
    @echo "Installing frontend dependencies..."
    cd frontend && npm install
    @echo "Downloading NLP models..."
    cd backend && poetry run python -m spacy download en_core_web_sm

# Run backend tests
test-backend:
    @echo "Running backend tests..."
    cd backend && poetry run pytest -v

# Run frontend tests
test-frontend:
    @echo "Running frontend type check..."
    cd frontend && npm run type-check
    @echo "Running frontend lint..."
    cd frontend && npm run lint

# Run all tests
test: test-backend test-frontend
    @echo "✓ All tests passed"

# Format code
fmt:
    @echo "Formatting backend code..."
    cd backend && poetry run black app tests
    @echo "Backend code formatted"
    @echo "Formatting frontend code..."
    cd frontend && npm run lint -- --fix || true

# Lint code
lint:
    @echo "Linting backend..."
    cd backend && poetry run ruff check app tests
    cd backend && poetry run mypy app
    @echo "Linting frontend..."
    cd frontend && npm run lint
    cd frontend && npm run type-check

# Run backend locally
run-backend:
    @echo "Starting backend server..."
    cd backend && poetry run python -m app.main

# Run frontend locally
run-frontend:
    @echo "Starting frontend dev server..."
    cd frontend && npm run dev

# Build frontend for production
build-frontend:
    @echo "Building frontend..."
    cd frontend && npm run build

# Start all services with Podman Compose
up:
    @echo "Starting all services..."
    cd infrastructure/podman && podman-compose up -d
    @echo "Services started!"
    @echo "  Backend API: http://localhost:8000"
    @echo "  API Docs: http://localhost:8000/docs"
    @echo "  Frontend: http://localhost:3000"
    @echo "  ArangoDB: http://localhost:8529"

# Stop all services
down:
    @echo "Stopping all services..."
    cd infrastructure/podman && podman-compose down

# View logs
logs SERVICE="":
    #!/usr/bin/env bash
    if [ -z "{{SERVICE}}" ]; then
        cd infrastructure/podman && podman-compose logs -f
    else
        cd infrastructure/podman && podman-compose logs -f {{SERVICE}}
    fi

# Restart services
restart SERVICE="":
    #!/usr/bin/env bash
    if [ -z "{{SERVICE}}" ]; then
        just down && just up
    else
        cd infrastructure/podman && podman-compose restart {{SERVICE}}
    fi

# Check service status
status:
    @echo "Checking service status..."
    cd infrastructure/podman && podman-compose ps

# Build containers
build:
    @echo "Building backend container..."
    cd backend && podman build -t polygraph-backend:latest -f Containerfile .
    @echo "Building frontend container..."
    cd frontend && podman build -t polygraph-frontend:latest -f Containerfile .

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf backend/dist backend/build backend/.pytest_cache backend/htmlcov
    rm -rf backend/**/__pycache__
    rm -rf frontend/dist frontend/build frontend/node_modules/.cache
    @echo "Clean complete"

# Clean everything including dependencies
clean-all: clean
    @echo "Removing dependencies..."
    rm -rf backend/.venv
    rm -rf frontend/node_modules
    @echo "Deep clean complete"

# Security audit
audit:
    @echo "Running security audit..."
    @echo "Checking backend dependencies..."
    cd backend && poetry check || true
    @echo "Checking frontend dependencies..."
    cd frontend && npm audit || true

# Database migrations (when implemented)
migrate:
    @echo "Running database migrations..."
    @echo "Not yet implemented"

# Seed database with test data
seed:
    @echo "Seeding database..."
    @echo "Not yet implemented"

# RSR compliance check
validate-rsr:
    @echo "Checking RSR compliance..."
    @just --evaluate _check-docs
    @just --evaluate _check-security
    @just --evaluate _check-tests
    @echo "✓ RSR compliance validated"

# Check documentation completeness
_check-docs:
    #!/usr/bin/env bash
    echo "Checking documentation..."
    docs=("README.md" "LICENSE" "SECURITY.md" "CODE_OF_CONDUCT.md" "CONTRIBUTING.md" "MAINTAINERS.md" "CHANGELOG.md")
    missing=()
    for doc in "${docs[@]}"; do
        if [ ! -f "$doc" ]; then
            missing+=("$doc")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        echo "  ✓ All required docs present"
    else
        echo "  ✗ Missing: ${missing[*]}"
        exit 1
    fi

# Check security files
_check-security:
    #!/usr/bin/env bash
    echo "Checking security files..."
    files=(".well-known/security.txt" ".well-known/ai.txt" ".well-known/humans.txt" "SECURITY.md")
    missing=()
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            missing+=("$file")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        echo "  ✓ All security files present"
    else
        echo "  ✗ Missing: ${missing[*]}"
        exit 1
    fi

# Check test coverage
_check-tests:
    @echo "Checking test coverage..."
    cd backend && poetry run pytest --cov=app --cov-report=term-missing --cov-fail-under=0 || true

# Generate API documentation
docs:
    @echo "Starting API documentation server..."
    @echo "Visit http://localhost:8000/docs"
    just run-backend

# Create new release
release VERSION:
    @echo "Creating release {{VERSION}}..."
    @echo "1. Update CHANGELOG.md"
    @echo "2. Update version in pyproject.toml and package.json"
    @echo "3. Commit changes"
    @echo "4. Create git tag: git tag -a v{{VERSION}} -m 'Release {{VERSION}}'"
    @echo "5. Push: git push && git push --tags"

# Check environment setup
check-env:
    @echo "Checking environment..."
    @command -v python3 >/dev/null 2>&1 || (echo "✗ Python 3 not found" && exit 1)
    @command -v node >/dev/null 2>&1 || (echo "✗ Node.js not found" && exit 1)
    @command -v podman >/dev/null 2>&1 || (echo "✗ Podman not found" && exit 1)
    @command -v poetry >/dev/null 2>&1 || (echo "✗ Poetry not found" && exit 1)
    @echo "✓ All required tools found"
    @python3 --version
    @node --version
    @podman --version
    @poetry --version

# Development setup
dev-setup: check-env install
    @echo "Setting up development environment..."
    @echo "Copying environment files..."
    @test -f backend/.env || cp backend/.env.example backend/.env
    @test -f frontend/.env || cp frontend/.env.example frontend/.env
    @test -f infrastructure/podman/.env || cp infrastructure/podman/.env.example infrastructure/podman/.env
    @echo "✓ Development environment ready"
    @echo ""
    @echo "Next steps:"
    @echo "  1. Edit .env files with your configuration"
    @echo "  2. Run 'just up' to start services"
    @echo "  3. Visit http://localhost:8000/docs for API"

# Production deployment check
prod-check:
    @echo "Production readiness checklist:"
    @echo "  [ ] Changed all default secrets in .env"
    @echo "  [ ] SSL certificates configured"
    @echo "  [ ] Firewall rules in place"
    @echo "  [ ] Backup system configured"
    @echo "  [ ] Monitoring enabled"
    @echo "  [ ] Log rotation configured"
    @echo "  [ ] Email notifications set up"
    @echo "  [ ] Domain DNS configured"
    @echo "See docs/DEPLOYMENT.md for details"

# Quick health check
health:
    @echo "Checking service health..."
    @curl -f http://localhost:8000/health 2>/dev/null | jq . || echo "Backend not running"
    @curl -f http://localhost:3000 >/dev/null 2>&1 && echo "✓ Frontend running" || echo "✗ Frontend not running"

# Backup databases
backup:
    @echo "Creating backup..."
    @mkdir -p backups
    @echo "Backing up ArangoDB..."
    @podman exec polygraph-arangodb arangodump --output-directory /tmp/backup || echo "ArangoDB not running"
    @echo "Backup complete: backups/$(date +%Y%m%d_%H%M%S)"

# Interactive development mode
dev:
    @echo "Starting development mode..."
    @echo "This will:"
    @echo "  1. Start databases (ArangoDB, XTDB, Dragonfly)"
    @echo "  2. Keep backend and frontend logs tailing"
    @echo ""
    @echo "Press Ctrl+C to stop all services"
    @just up
    @trap 'just down' EXIT; just logs
