# Rock Paper Scissors

A web-based application that allows a user to play Rock-Paper-Scissors against a server API. Built with Rails 8 and Hotwire, featuring a clean three-layer architecture with resilient API integration and offline fallback capabilities.

## Features

- **API Integration**: Fetches opponent throws from the Curb RPS API
- **Offline Fallback**: Automatically falls back to local random generation when API is unavailable
- **Extensible Design**: Add new throws (like "hammer") by updating a single registry
- **Progressive Enhancement**: Works without JavaScript; JS adds polish and interactivity

## Architecture Overview

This project follows a clean three-layer architecture that separates concerns and enables independent testing of each layer:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│         GamesController + Hotwire (Turbo + Stimulus)        │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│                  Api::ThrowClient                            │
│         (HTTP client with retry + fallback)                  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│              Game::Throw, Game::Rules, Game::Resolver        │
│                    (Pure Ruby, no Rails)                     │
└─────────────────────────────────────────────────────────────┘
```

### Domain Layer (`app/models/game/`)

- **`Throw`**: Value object representing a game throw with validation
- **`Rules`**: Registry defining what beats what (single source of truth)
- **`Resolver`**: Determines win/lose/tie outcomes using registry lookup

### Service Layer (`app/services/api/`)

- **`ThrowClient`**: HTTP client with 5s connect timeout, 10s read timeout, 1 retry on failure, and local fallback

### Presentation Layer

- **`GamesController`**: Thin orchestration layer (no business logic)
- **Turbo**: Server-side rendering with SPA-like page updates
- **Stimulus**: Progressive enhancement for loading states and interactivity

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

## Design Decisions & Rationale

### 1. Registry Pattern for Rules (Open/Closed Principle)

The `Game::Rules` class uses a registry pattern—a hash mapping each throw to what it beats:

```ruby
RULES = {
  rock: [:scissors],
  paper: [:rock, :hammer],
  scissors: [:paper],
  hammer: [:scissors, :rock]
}.freeze
```

**Why this approach?**
- **Extensibility**: Adding new throws requires only updating this hash
- **No scattered conditionals**: No `if/else` or `case` statements throughout the codebase
- **Single source of truth**: All game rules live in one place
- **Testability**: Easy to verify all rules with exhaustive tests

### 2. Value Object Pattern for Throws

`Game::Throw` is an immutable value object that validates at creation time:

```ruby
throw = Game::Throw.new("rock")  # Valid
throw = Game::Throw.new("invalid")  # Raises ArgumentError
```

**Benefits:**
- **Fail-fast validation**: Invalid throws are caught immediately
- **Immutability**: Once created, a throw cannot change
- **Equality semantics**: Two throws with the same name are equal
- **Hash compatibility**: Can be used as hash keys

### 3. Resilient Service Layer with Fallback

`Api::ThrowClient` implements the Circuit Breaker pattern with graceful degradation:

```ruby
Result = Struct.new(:throw_name, :source, keyword_init: true)
# source is :api or :fallback
```

**Resilience features:**
- **5-second connect timeout**: Fail fast on network issues
- **10-second read timeout**: Don't block on slow responses
- **1 automatic retry**: Handle transient failures
- **Local fallback**: App always works, even offline
- **Transparent tracking**: UI can show "offline mode" indicator

### 4. Thin Controllers

`GamesController` is only 30 lines and contains no business logic:

```ruby
def play
  player_throw = validate_throw_param!
  opponent_result = Api::ThrowClient.fetch
  @result = Game::Resolver.new(
    player_throw: player_throw,
    opponent_throw: opponent_result.throw_name
  )
end
```

**Why thin controllers?**
- **Testability**: Domain logic tested without HTTP context
- **Reusability**: Game logic works in console, background jobs, etc.
- **Clarity**: Each layer has a single responsibility

### 5. Progressive Enhancement with Stimulus

The application renders everything server-side; JavaScript adds polish:

```javascript
// Stimulus controller manages:
// - Loading modal while waiting for API
// - Button disabled states during submission
// - Delayed form submission for smooth UX
```

**Advantages:**
- **Works without JS**: Core functionality doesn't require JavaScript
- **SEO-friendly**: Server-rendered content
- **Accessible**: Forms work with assistive technology
- **Resilient**: Graceful degradation on JS errors

## Installation

### Prerequisites

- **Ruby**: 3.4.4 (via rbenv recommended)
- **Node**: 25.x (via nvm recommended)

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd rock_paper_scissors

# Install Ruby dependencies
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

The `Api::ThrowClient` service handles various failure scenarios:

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

Game rules are defined in a registry pattern (`app/models/game/rules.rb`):

```ruby
RULES = {
  rock: [:scissors],
  paper: [:rock],
  scissors: [:paper]
}.freeze
```

The `Game::Resolver` uses this registry to determine outcomes—no conditionals or switch statements.

### Adding Hammer (or any new throw)

1. **Update the rules registry** in `app/models/game/rules.rb`:

```ruby
RULES = {
  rock: [:scissors],
  paper: [:rock, :hammer],  # Paper now also beats hammer
  scissors: [:paper],
  hammer: [:scissors, :rock]  # Hammer beats scissors and rock
}.freeze
```

2. **Add an icon partial** at `app/views/games/icons/_hammer.html.erb`

3. **Add the button** to `app/views/games/index.html.erb`:

```erb
<button type="submit"
        name="throw"
        value="hammer"
        class="group flex flex-col items-center p-8 rounded-lg hover:bg-gray-50 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-purple-dark/30 disabled:opacity-30 disabled:cursor-not-allowed"
        data-game-target="button"
        data-throw="hammer">
  <div class="mb-4">
    <%= render "games/icons/hammer" %>
  </div>
  <span class="font-roboto text-purple-dark text-lg capitalize">hammer</span>
</button>
```

No changes needed to `Game::Throw`, `Game::Resolver`, or `GamesController`!

## Future Improvements

This section outlines potential enhancements organized by category. These suggestions could serve as a roadmap for further development or as inspiration for contributors.

### Feature Enhancements

| Improvement | Description | Complexity |
|-------------|-------------|------------|
| **Game History** | Persist game results to database, show win/loss statistics | Medium |
| **User Accounts** | Authentication with Devise, personal stats tracking | Medium |
| **Multiplayer Mode** | Real-time player-vs-player using Action Cable WebSockets | High |
| **Lizard-Spock Variant** | Add "Lizard" and "Spock" throws (Big Bang Theory rules) | Low |
| **Leaderboard** | Global rankings based on win rate or streaks | Medium |
| **Game Replays** | View history of past games with timestamps | Low |

### Technical Improvements

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **System Tests** | Add Capybara tests for full browser automation | End-to-end confidence |
| **JavaScript Tests** | Jest tests for Stimulus controllers | Frontend reliability |
| **API Circuit Breaker** | Use gems like `circuitbox` for smarter failure handling | Better resilience |
| **Response Caching** | Cache API responses briefly to reduce latency | Performance |
| **Request Logging** | Structured logging with correlation IDs | Observability |
| **Health Check Endpoint** | `/health` endpoint for monitoring | DevOps readiness |

### Infrastructure & DevOps

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Docker Support** | Dockerfile and docker-compose for containerized deployment | Portability |
| **CI/CD Pipeline** | GitHub Actions for automated testing and deployment | Automation |
| **Error Tracking** | Integration with Sentry or Honeybadger | Production visibility |
| **Performance Monitoring** | APM with Skylight or New Relic | Performance insights |
| **Staging Environment** | Heroku/Render staging app for pre-production testing | Safer deployments |

### User Experience

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Sound Effects** | Audio feedback for wins, losses, and throws | Engagement |
| **Animations** | CSS/JS animations for throw reveals | Polish |
| **Dark Mode** | Toggle between light and dark themes | Accessibility |
| **Internationalization** | i18n support for multiple languages | Global reach |
| **Mobile PWA** | Progressive Web App with offline support | Mobile experience |
| **Keyboard Shortcuts** | Press R/P/S keys to select throws | Power users |

### Code Quality

| Improvement | Description | Benefit |
|-------------|-------------|---------|
| **Test Coverage Reporting** | SimpleCov integration with coverage thresholds | Quality metrics |
| **API Documentation** | OpenAPI/Swagger spec for the game endpoint | Developer experience |
| **Type Checking** | Sorbet or RBS for Ruby type annotations | Type safety |
| **Mutation Testing** | Mutant gem to verify test effectiveness | Test quality |
| **Performance Benchmarks** | Benchmark scripts for critical paths | Regression prevention |

### Quick Wins (Good First Issues)

These improvements are ideal for contributors getting started:

1. **Add favicon** - Custom rock-paper-scissors favicon
2. **Meta tags** - Open Graph tags for social sharing
3. **404 page** - Custom error page matching the design
4. **Loading skeleton** - Skeleton UI while page loads
5. **Tooltip hints** - Hover tooltips explaining game rules

### Architecture Evolution

For a production-scale application, consider:

```
Current: Monolith (Rails MVC)
    │
    ▼
Phase 1: Add Background Jobs (Sidekiq)
    - Async API calls
    - Email notifications for achievements
    │
    ▼
Phase 2: Extract Game Service
    - Separate game logic into a service
    - Enable multiple frontends (web, mobile API)
    │
    ▼
Phase 3: Event-Driven Architecture
    - Publish game events to message queue
    - Analytics, achievements, notifications as consumers
```

## Tech Stack

- **Rails 8** - Modern Ruby web framework
- **Hotwire (Turbo + Stimulus)** - SPA-like interactivity without heavy JavaScript
- **Tailwind CSS 4** - Utility-first styling matching the mockup
- **TypeScript** - Type-safe JavaScript for Stimulus controllers
- **RSpec** - Testing framework with WebMock for API mocking
