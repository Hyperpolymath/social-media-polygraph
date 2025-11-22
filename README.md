# Social Media Polygraph

> AI-powered fact-checking and misinformation detection for social media

[![CI/CD](https://github.com/hyperpolymath/social-media-polygraph/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/hyperpolymath/social-media-polygraph/actions)
[![License](https://img.shields.io/badge/license-MIT%20%2B%20Palimpsest-blue.svg)](LICENSE)
[![RSR Compliance](https://img.shields.io/badge/RSR-Silver-blue.svg)](scripts/check-rsr-compliance.sh)
[![Security](https://img.shields.io/badge/security-RFC%209116-green.svg)](.well-known/security.txt)

## Overview

Social Media Polygraph is a comprehensive, AI-powered platform for verifying claims and detecting misinformation on social media. It combines advanced Natural Language Processing (NLP), multiple fact-checking databases, source credibility analysis, and temporal tracking to provide accurate, reliable verification results.

## Features

- **🔍 Multi-Source Verification**: Cross-references claims with multiple fact-checking services
- **🤖 Advanced NLP**: Entity extraction, sentiment analysis, and claim decomposition
- **📊 Credibility Scoring**: Sophisticated algorithms evaluate source reliability
- **⏱️ Temporal Tracking**: Track how claim verifications change over time using XTDB
- **🌐 RESTful API**: Full-featured API with authentication and rate limiting
- **💻 Web Interface**: Modern React frontend for easy claim verification
- **🔌 Browser Extension**: In-context fact-checking on social media platforms
- **📈 Analytics**: Comprehensive metrics and reporting

## Technology Stack

### Backend
- **Python 3.11** with FastAPI
- **ArangoDB** - Multi-model database (document, graph, key-value)
- **XTDB** - Temporal database for claim history tracking
- **Dragonfly** - High-performance Redis-compatible cache
- **spaCy & Transformers** - NLP and ML models
- **Poetry** - Dependency management

### Frontend
- **React 18** with TypeScript
- **Vite** - Fast build tool
- **TailwindCSS** - Styling
- **React Query** - Data fetching
- **React Router** - Navigation

### Infrastructure
- **Podman** - Container runtime
- **Podman Compose** - Multi-container orchestration
- **GitHub Actions** - CI/CD

## Quick Start

### Prerequisites

- Python 3.11+
- Node.js 20+
- Podman or Docker
- Poetry (for Python dependency management)

### Option 1: Using Podman Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/hyperpolymath/social-media-polygraph.git
cd social-media-polygraph

# Start all services
./scripts/start-dev.sh
```

This will start:
- Backend API: http://localhost:8000
- Frontend: http://localhost:3000
- ArangoDB: http://localhost:8529
- XTDB: http://localhost:3000
- Dragonfly: localhost:6379

API Documentation: http://localhost:8000/docs

### Option 2: Manual Setup

#### Backend Setup

```bash
cd backend

# Install dependencies
poetry install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration

# Run database migrations (if applicable)
# poetry run alembic upgrade head

# Download NLP models
poetry run python -m spacy download en_core_web_sm

# Run the server
poetry run python -m app.main
```

#### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Start development server
npm run dev
```

## API Usage

### Verify a Claim

```bash
curl -X POST "http://localhost:8000/api/v1/claims/verify" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The Earth is flat",
    "url": "https://example.com/post",
    "platform": "twitter"
  }'
```

### Response

```json
{
  "success": true,
  "claim_id": "abc123",
  "analysis": {
    "claim": {
      "id": "abc123",
      "text": "The Earth is flat",
      "status": "verified"
    },
    "verification": {
      "verdict": "false",
      "confidence": 0.95,
      "explanation": "This claim has been thoroughly debunked by scientific evidence...",
      "fact_checks": [
        {
          "source": "Science Fact Checker",
          "verdict": "false",
          "rating": 0.95
        }
      ],
      "credibility_score": 0.15
    }
  },
  "processing_time": 1.234
}
```

## Browser Extension

### Installation

1. Navigate to `browser-extension` directory
2. Load as unpacked extension in Chrome/Edge:
   - Open `chrome://extensions`
   - Enable "Developer mode"
   - Click "Load unpacked"
   - Select the `browser-extension` directory

### Usage

- Right-click selected text and choose "Verify with Polygraph"
- Click extension icon and paste claim to verify
- On supported platforms (Twitter/X), verify buttons appear on posts

## Development

### Running Tests

#### Backend

```bash
cd backend
poetry run pytest
poetry run pytest --cov=app --cov-report=html
```

#### Frontend

```bash
cd frontend
npm run test
npm run type-check
npm run lint
```

### Code Quality

```bash
# Backend
cd backend
poetry run black app tests
poetry run ruff check app tests
poetry run mypy app

# Frontend
cd frontend
npm run lint
npm run type-check
```

## Project Structure

```
social-media-polygraph/
├── backend/                 # Python FastAPI backend
│   ├── app/
│   │   ├── api/            # API endpoints
│   │   ├── core/           # Core configuration
│   │   ├── db/             # Database clients
│   │   ├── ml/             # ML/NLP modules
│   │   ├── models/         # Pydantic models
│   │   └── services/       # Business logic
│   └── tests/              # Backend tests
├── frontend/               # React frontend
│   └── src/
│       ├── components/     # React components
│       ├── pages/          # Page components
│       ├── services/       # API clients
│       └── types/          # TypeScript types
├── browser-extension/      # Browser extension
│   ├── src/               # Extension code
│   └── public/            # Extension assets
├── infrastructure/        # Infrastructure configs
│   └── podman/           # Podman compose files
├── scripts/              # Utility scripts
└── docs/                 # Documentation
```

## Configuration

### Environment Variables

#### Backend (.env)

```env
# Application
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret

# Databases
ARANGO_HOST=localhost
ARANGO_PASSWORD=changeme
XTDB_NODE_URL=http://localhost:3000
DRAGONFLY_HOST=localhost

# External APIs (optional)
OPENAI_API_KEY=your-key
ANTHROPIC_API_KEY=your-key
NEWSAPI_KEY=your-key

# Features
ENABLE_FACT_CHECKING=true
ENABLE_TEMPORAL_TRACKING=true
```

#### Frontend (.env)

```env
VITE_API_URL=http://localhost:8000
```

## API Documentation

Full API documentation is available at `/docs` (Swagger UI) and `/redoc` (ReDoc) when running the backend server.

Key endpoints:

- `POST /api/v1/claims/verify` - Verify a claim
- `GET /api/v1/claims/{id}` - Get claim analysis
- `GET /api/v1/claims/{id}/history` - Get claim verification history
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login
- `GET /health` - Health check

## Architecture

### Data Flow

1. **Claim Submission** → User submits claim via API, web UI, or extension
2. **Text Processing** → NLP extracts entities, analyzes sentiment
3. **Fact Checking** → Query multiple fact-checking databases
4. **Credibility Scoring** → Algorithm calculates credibility score
5. **Storage** → Store in ArangoDB, track in XTDB
6. **Caching** → Cache results in Dragonfly
7. **Response** → Return comprehensive analysis to user

### Database Design

- **ArangoDB**: Main data store with graph capabilities for relationships
- **XTDB**: Temporal database tracking claim verification history
- **Dragonfly**: High-performance cache for API responses

## Contributing

We welcome contributions! This project follows the **Tri-Perimeter Contribution Framework (TPCF)**:

- **Perimeter 3 (Community Sandbox)**: Open to all - submit PRs from forks
- **Perimeter 2 (Trusted Contributors)**: Regular contributors with proven track record
- **Perimeter 1 (Core Maintainers)**: Project leadership and decision-making

See [CONTRIBUTING.md](CONTRIBUTING.md) and [MAINTAINERS.md](MAINTAINERS.md) for details.

### Quick Start

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Ethics & Responsible Use

This tool is designed to combat misinformation and should be used responsibly:

- **Transparency**: We show sources and reasoning for all verdicts
- **Privacy**: User data is handled securely and never sold
- **Bias Mitigation**: Algorithms are designed to minimize bias
- **Human Oversight**: Automated verdicts should be reviewed
- **Platform ToS**: Respect social media platform terms of service

## License

This project is **dual-licensed**:

- **[MIT License](LICENSE)** - Permissive open source license
- **[Palimpsest License v0.8](LICENSE-PALIMPSEST.txt)** - Adds ethical use guidelines

You may choose which license to follow. The Palimpsest License provides additional community expectations around:
- Ethical use (no surveillance, weapons, discrimination)
- Attribution and transparency
- Privacy and accessibility
- Community contribution

See [LICENSE-PALIMPSEST.txt](LICENSE-PALIMPSEST.txt) for full details.

## Acknowledgments

- Fact-checking databases and APIs
- spaCy and Hugging Face for NLP models
- Open-source community

## RSR Framework Compliance

This project follows the **Rhodium Standard Repository (RSR)** framework for high-quality, maintainable open source software.

**Current Status**: Silver Level ⭐

Run compliance check:
```bash
just validate-rsr
# or
./scripts/check-rsr-compliance.sh
```

### RSR Standards Met

✅ **Documentation**: Complete (README, SECURITY, CODE_OF_CONDUCT, CONTRIBUTING, MAINTAINERS, CHANGELOG)
✅ **.well-known**: RFC 9116 security.txt, ai.txt, humans.txt
✅ **Build System**: justfile with 30+ recipes
✅ **Testing**: Comprehensive test suites
✅ **CI/CD**: GitHub Actions workflows
✅ **Security**: Vulnerability disclosure, dual licensing
✅ **Community**: TPCF governance model
✅ **Type Safety**: TypeScript + Python type hints
✅ **Containerization**: Podman/Docker support

## Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/hyperpolymath/social-media-polygraph/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hyperpolymath/social-media-polygraph/discussions)
- **Security**: See [SECURITY.md](SECURITY.md)
- **Humans**: See [.well-known/humans.txt](.well-known/humans.txt)

## Roadmap

- [ ] Real-time claim monitoring
- [ ] Multi-language support
- [ ] Mobile applications
- [ ] Enhanced ML models
- [ ] Integration with more fact-checking services
- [ ] Advanced analytics dashboard
- [ ] API webhooks
- [ ] Export functionality (PDF, CSV reports)

---

Built with ❤️ for a more informed internet
