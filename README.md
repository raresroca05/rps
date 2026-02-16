# Rock Paper Scissors

A web-based application that allows a user to play Rock-Paper-Scissors against a server API. Built with Rails 8 and Hotwire, featuring a **Rails Engines architecture** with Domain-Driven Design (DDD), comprehensive Design Patterns, and SOLID principles throughout.

## Features

- **API Integration**: Fetches opponent throws from the Curb RPS API
- **Offline Fallback**: Automatically falls back to local random generation when API is unavailable
- **Extensible Design**: Add new throws (like "hammer") by updating a single registry
- **Progressive Enhancement**: Works without JavaScript; JS adds polish and interactivity
- **Modular Architecture**: Rails Engines enable extraction and reuse

## Architecture Overview

This project implements a **modular monolith** using Rails Engines, following Domain-Driven Design principles:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Main Application                                 │
│                    (GamesController + Views)                            │
│                                                                          │
│   ┌─────────────────────┐         ┌─────────────────────────────────┐  │
│   │   Game:: Aliases    │         │      Api:: Adapter              │  │
│   │   (Backward Compat) │         │      (Backward Compat)          │  │
│   └──────────┬──────────┘         └───────────────┬─────────────────┘  │
└──────────────┼────────────────────────────────────┼─────────────────────┘
               │                                    │
               ▼                                    ▼
┌──────────────────────────────┐    ┌────────────────────────────────────┐
│        engines/game_core     │    │       engines/opponent_api         │
│                              │    │                                    │
│  ┌────────────────────────┐  │    │  ┌──────────────────────────────┐  │
│  │   GameCore::Domain     │  │    │  │    OpponentApi::Client       │  │
│  │                        │  │    │  │         (Facade)             │  │
│  │  • Throw (Value Obj)   │  │    │  └──────────────┬───────────────┘  │
│  │  • Rules (Registry)    │  │    │                 │                  │
│  │  • Result (Value Obj)  │  │    │  ┌──────────────▼───────────────┐  │
│  │  • Resolver (Service)  │  │    │  │   Strategies::Base           │  │
│  └────────────────────────┘  │    │  │   (Strategy Pattern)         │  │
│                              │    │  │                              │  │
│  Pure Ruby - No Rails Deps   │    │  │  ├── Strategies::Http        │  │
│                              │    │  │  └── Strategies::Fallback    │  │
└──────────────────────────────┘    │  └──────────────────────────────┘  │
                                    └────────────────────────────────────┘
```

### Engine: `game_core`

**Bounded Context**: Core game domain logic

| Component | DDD Pattern | SOLID Principles |
|-----------|-------------|------------------|
| `Domain::Throw` | Value Object | SRP, OCP |
| `Domain::Rules` | Registry/Repository | SRP, OCP, DIP |
| `Domain::Result` | Value Object | SRP |
| `Domain::Resolver` | Domain Service | SRP, OCP, DIP |

**Key Characteristics:**
- Pure Ruby with no Rails dependencies in domain layer
- Immutable Value Objects (frozen after creation)
- Single source of truth for game rules
- Can be extracted as a standalone gem

### Engine: `opponent_api`

**Bounded Context**: External opponent integration

| Component | Design Pattern | Purpose |
|-----------|---------------|---------|
| `Client` | Facade | Simple interface to strategy subsystem |
| `Strategies::Base` | Template Method | Defines algorithm structure |
| `Strategies::Http` | Strategy | HTTP API implementation |
| `Strategies::Fallback` | Strategy | Local random fallback |
| `Result` | Value Object | Immutable API response |

**Key Characteristics:**
- Strategy Pattern enables swappable opponent providers
- Automatic fallback on failure (Chain of Responsibility)
- Configurable timeouts and retry logic
- Extensible for new providers (mock, WebSocket, etc.)

## Design Patterns Applied

### 1. Registry Pattern (Game Rules)

```ruby
# engines/game_core/app/models/game_core/domain/rules.rb
RULES = {
  rock: [:scissors],
  paper: [:rock, :hammer],
  scissors: [:paper],
  hammer: [:scissors, :rock]
}.freeze
```

**Benefits:**
- Single source of truth for all game rules
- Adding throws requires only data changes
- No conditional logic scattered through codebase

### 2. Value Object Pattern (Throws & Results)

```ruby
# Immutable, equality by attributes
throw1 = GameCore::Domain::Throw.new("rock")
throw2 = GameCore::Domain::Throw.new("rock")
throw1 == throw2  # => true (same value, different objects)
throw1.freeze     # Already frozen - immutable by design
```

**Benefits:**
- Thread-safe by default
- Can be used as hash keys
- Fail-fast validation

### 3. Strategy Pattern (Opponent Generation)

```ruby
# Swappable strategies
http_client = OpponentApi::Client.new(strategy: :http)
fallback_client = OpponentApi::Client.new(strategy: :fallback)

# Both produce the same Result interface
result = http_client.fetch
result.throw_name  # => :rock
result.source      # => :api or :fallback
```

**Benefits:**
- Easy to add new opponent sources
- Testing with mock strategies
- Runtime strategy selection

### 4. Facade Pattern (API Client)

```ruby
# Simple interface hides complexity
result = OpponentApi::Client.fetch

# Behind the scenes:
# - Selects appropriate strategy
# - Handles retries
# - Falls back on failure
# - Returns consistent Result
```

### 5. Adapter Pattern (Backward Compatibility)

```ruby
# app/models/game/throw.rb
module Game
  Throw = GameCore::Domain::Throw  # Alias to engine
end

# Existing code continues to work
throw = Game::Throw.new("rock")
```

## SOLID Principles in Action

### Single Responsibility Principle (SRP)

| Class | Single Responsibility |
|-------|----------------------|
| `Throw` | Represent a valid throw |
| `Rules` | Define and query game rules |
| `Resolver` | Determine game outcomes |
| `Http` strategy | HTTP communication |
| `Fallback` strategy | Local random generation |

### Open/Closed Principle (OCP)

```ruby
# Adding "lizard" and "spock" - NO code changes needed!
RULES = {
  rock: [:scissors, :lizard],
  paper: [:rock, :spock],
  scissors: [:paper, :lizard],
  lizard: [:paper, :spock],
  spock: [:rock, :scissors]
}.freeze
# Resolver, Throw, Controller - all unchanged
```

### Liskov Substitution Principle (LSP)

```ruby
# Any strategy can substitute another
def fetch_opponent(strategy)
  strategy.fetch  # Works with Http, Fallback, or any future strategy
end
```

### Interface Segregation Principle (ISP)

```ruby
# Strategies only implement what they need
class Strategies::Base
  def fetch; end        # Required
  def perform_fetch; end  # Template method
end
# No bloated interfaces
```

### Dependency Inversion Principle (DIP)

```ruby
# Throw depends on Rules abstraction, not concrete implementation
class Throw
  def beats?(other)
    Rules.beats?(@name, other.name)  # Depends on interface
  end
end
```

## Development Journey

This project was built incrementally through a series of focused commits:

| # | Focus | Purpose |
|---|-------|---------|
| 1 | Domain Models | Game logic with `Throw`, `Rules`, and `Resolver` using registry pattern |
| 2 | API Client | `ThrowClient` with timeout, retry, and local fallback |
| 3 | Controller & Route | `GamesController#play` action and routing |
| 4 | Views | Start screen and result page with hand icons |
| 5 | Interactivity | Stimulus controller for loading modal and button states |
| 6 | Testing | RSpec tests for models, API client, and request specs |
| 7 | Documentation | Initial README with installation and gameplay |
| 8 | UI Polish | Styling aligned with Adobe XD mockups |
| 9 | Extensibility | Added "hammer" throw to demonstrate Open/Closed Principle |
| 10 | Code Quality | Rubocop linting and style fixes |
| 11 | **Rails Engines** | Extracted domain into modular engines with DDD |

## Installation

### Prerequisites

- **Ruby**: 3.4.4 (via rbenv recommended)
- **Node**: 25.x (via nvm recommended)

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd rock_paper_scissors

# Install Ruby dependencies (includes engines)
bundle install

# Install JavaScript dependencies
yarn install

# Set up the database
bin/rails db:prepare
```

## Running the Application

```bash
bin/dev
```

Visit `http://localhost:3000` to play!

## How to Play

1. Select your throw: Rock, Paper, or Scissors
2. Wait for the server's response
3. See the result: Win, Lose, or Tie!
4. Click "Play Again" for another round

### Game Rules

| Throw    | Beats         |
|----------|---------------|
| Rock     | Scissors      |
| Paper    | Rock, Hammer  |
| Scissors | Paper         |
| Hammer   | Scissors, Rock|

Identical throws result in a tie.

## Testing Guide

### Running All Tests

```bash
bundle exec rspec
```

### Running Specific Test Files

```bash
# Domain models
bundle exec rspec spec/models/game/

# Specific model
bundle exec rspec spec/models/game/resolver_spec.rb

# API client
bundle exec rspec spec/services/api/throw_client_spec.rb

# Controller integration
bundle exec rspec spec/requests/games_spec.rb
```

### Test Coverage Areas

| Area | File | Tests |
|------|------|-------|
| Domain Logic | `spec/models/game/*_spec.rb` | Throw validation, rules registry, outcome resolution |
| API Client | `spec/services/api/throw_client_spec.rb` | Success, timeout, retry, fallback scenarios |
| Integration | `spec/requests/games_spec.rb` | Full request/response cycle |

## Requirements Implemented

### Core Functionality

- **User choice**: The user can select rock, paper, or scissors via clickable buttons
- **API integration**: The application calls the [Curb RPS API](https://curbrockpaperscissors.docs.apiary.io) to retrieve the server's throw
- **Result display**: A result page shows whether the user won, lost, or tied

### Non-Happy Path Handling

The `OpponentApi::Client` service handles various failure scenarios:

- **Network timeouts**: 5s connect timeout, 10s read timeout
- **Automatic retry**: 1 retry on transient failures
- **API errors**: Handles HTTP 500 responses gracefully
- **Invalid responses**: Validates the response contains a valid throw

When any error occurs, the application falls back to generating a random throw locally and indicates "offline mode" to the user.

### User Interface

The UI implements the [Adobe XD mockup](https://xd.adobe.com/spec/9f82f558-f25b-4982-7ded-1f2b5e0fe897-e9b3/) with:

- Clean, centered layout on white background
- Custom hand icons for each throw option
- Loading modal with animation while waiting for server response
- Result modal displaying both throws and the outcome
- "Play Again" button to restart

## Extra Credit: Extensibility (Hammer)

The architecture supports adding new throws without modifying core game logic, following the Open/Closed Principle.

### How It Works

Game rules are defined in a registry pattern (`engines/game_core/app/models/game_core/domain/rules.rb`):

```ruby
RULES = {
  rock: [:scissors],
  paper: [:rock],
  scissors: [:paper]
}.freeze
```

The `GameCore::Domain::Resolver` uses this registry to determine outcomes—no conditionals or switch statements.

### Adding Hammer (or any new throw)

1. **Update the rules registry** in `engines/game_core/app/models/game_core/domain/rules.rb`:

```ruby
RULES = {
  rock: [:scissors],
  paper: [:rock, :hammer],
  scissors: [:paper],
  hammer: [:scissors, :rock]
}.freeze
```

2. **Add an icon partial** at `app/views/games/icons/_hammer.html.erb`

3. **Add the button** to `app/views/games/index.html.erb`

No changes needed to `Throw`, `Resolver`, `Client`, or `GamesController`!

## Future Improvements

### Architecture Improvements (Post-Engine Refactor)

Now that the codebase uses Rails Engines, these improvements become easier:

| Improvement | Description | Enabled By |
|-------------|-------------|------------|
| **Extract game_core as Gem** | Publish as standalone Ruby gem | Engine isolation |
| **Multiple API Providers** | Add WebSocket, GraphQL strategies | Strategy Pattern |
| **Plugin System** | Third-party rule extensions | Registry Pattern |
| **Microservice Extraction** | Deploy engines independently | Bounded Contexts |
| **A/B Testing Strategies** | Test different opponent algorithms | Strategy swapping |

### Engine-Specific Improvements

#### `game_core` Engine

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Aggregate Root** | Wrap Resolver + Result in Game aggregate | DDD completeness |
| **Domain Events** | Emit events on game completion | Event sourcing readiness |
| **Rule Validators** | Validate rule consistency (no cycles) | Data integrity |
| **Serializers** | JSON/YAML rule import/export | Configuration flexibility |
| **Game Variants** | Named rulesets (classic, lizard-spock) | Product variants |

#### `opponent_api` Engine

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Circuit Breaker** | Use `circuitbox` gem for smarter failures | Better resilience |
| **Strategy Registry** | Dynamic strategy registration | Plugin architecture |
| **Caching Strategy** | Cache API responses briefly | Performance |
| **Mock Strategy** | Deterministic testing strategy | Test reliability |
| **Metrics Strategy** | Decorator for observability | Monitoring |

### DDD & Pattern Improvements

| Pattern | Current | Future Enhancement |
|---------|---------|-------------------|
| **Aggregates** | Not used | Add Game aggregate containing Throws + Result |
| **Domain Events** | Not used | GamePlayed, GameWon events for analytics |
| **Specification** | Not used | Rule validation specs |
| **Repository** | Partial (Rules) | Full repository for persisted games |
| **Factory** | Basic | Abstract factory for game variants |

### SOLID Improvements

| Principle | Current State | Improvement |
|-----------|---------------|-------------|
| **SRP** | Good | Extract HTTP concerns from strategy |
| **OCP** | Excellent | Add rule validation hooks |
| **LSP** | Good | Add strategy interface tests |
| **ISP** | Good | Split Result into ApiResult/FallbackResult |
| **DIP** | Good | Inject Rules dependency |

### Feature Enhancements

| Improvement | Description | Complexity |
|-------------|-------------|------------|
| **Game History** | Persist game results to database | Medium |
| **User Accounts** | Authentication with Devise, personal stats | Medium |
| **Multiplayer Mode** | Real-time player-vs-player using Action Cable | High |
| **Lizard-Spock Variant** | Add "Lizard" and "Spock" throws | Low |
| **Leaderboard** | Global rankings based on win rate | Medium |
| **Game Replays** | View history of past games | Low |

### Technical Improvements

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Engine Tests** | Dedicated specs inside each engine | Isolation |
| **System Tests** | Capybara browser automation | E2E confidence |
| **OpenAPI Spec** | Document internal engine APIs | Developer experience |
| **Type Checking** | Sorbet/RBS annotations | Type safety |
| **Mutation Testing** | Mutant gem for test quality | Test effectiveness |

### Infrastructure & DevOps

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Docker Support** | Multi-stage build with engines | Portability |
| **CI Matrix** | Test each engine independently | Faster CI |
| **Engine Versioning** | Semantic versioning per engine | Change management |
| **Health Checks** | Per-engine health endpoints | Observability |

### Architecture Evolution Roadmap

```
Current: Modular Monolith (Rails Engines)
    │
    ├─── Near Term ───────────────────────────────────────┐
    │    • Extract game_core as gem (reuse in CLI, mobile) │
    │    • Add Domain Events for analytics                │
    │    • Implement Circuit Breaker in opponent_api      │
    └─────────────────────────────────────────────────────┘
    │
    ├─── Medium Term ─────────────────────────────────────┐
    │    • Add Game aggregate with persistence            │
    │    • WebSocket strategy for real-time opponents     │
    │    • Rule variants (classic, extended, custom)      │
    └─────────────────────────────────────────────────────┘
    │
    └─── Long Term ───────────────────────────────────────┐
         • Event-sourced game history                     │
         • Microservice extraction (game-service)        │
         • Multi-tenant rule customization               │
         └────────────────────────────────────────────────┘
```

## Tech Stack

- **Rails 8** - Modern Ruby web framework
- **Rails Engines** - Modular architecture with isolated bounded contexts
- **Hotwire (Turbo + Stimulus)** - SPA-like interactivity without heavy JavaScript
- **Tailwind CSS 4** - Utility-first styling matching the mockup
- **TypeScript** - Type-safe JavaScript for Stimulus controllers
- **RSpec** - Testing framework with WebMock for API mocking

## File Structure

```
rock_paper_scissors/
├── app/
│   ├── controllers/
│   │   └── games_controller.rb      # Thin orchestration layer
│   ├── models/game/                 # Backward-compatible aliases
│   │   ├── throw.rb                 # → GameCore::Domain::Throw
│   │   ├── rules.rb                 # → GameCore::Domain::Rules
│   │   └── resolver.rb              # → GameCore::Domain::Resolver
│   ├── services/api/
│   │   └── throw_client.rb          # Adapter → OpponentApi::Client
│   └── views/games/
│
├── engines/
│   ├── game_core/                   # Domain Logic Engine
│   │   ├── app/models/game_core/
│   │   │   ├── domain.rb            # Namespace
│   │   │   └── domain/
│   │   │       ├── throw.rb         # Value Object
│   │   │       ├── rules.rb         # Registry
│   │   │       ├── result.rb        # Value Object
│   │   │       └── resolver.rb      # Domain Service
│   │   ├── lib/game_core/
│   │   │   └── engine.rb
│   │   └── game_core.gemspec
│   │
│   └── opponent_api/                # API Integration Engine
│       ├── app/services/opponent_api/
│       │   ├── client.rb            # Facade
│       │   ├── result.rb            # Value Object
│       │   └── strategies/
│       │       ├── base.rb          # Template Method
│       │       ├── http.rb          # HTTP Strategy
│       │       └── fallback.rb      # Fallback Strategy
│       ├── lib/opponent_api/
│       │   └── engine.rb
│       └── opponent_api.gemspec
│
└── spec/
    ├── models/game/                 # Tests via aliases (backward compat)
    ├── services/api/
    └── requests/
```
