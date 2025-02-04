# Rock Paper Scissors

A Rails 8 web application for playing Rock-Paper-Scissors (with Hammer!) against a server API, featuring local fallback for offline play.

## Features

- Classic Rock-Paper-Scissors gameplay
- Extended with "Hammer" throw demonstrating extensibility
- External API integration for opponent moves
- Automatic fallback to local random throws when API is unavailable
- Modern UI with Tailwind CSS
- TypeScript for type-safe JavaScript
- Hotwire (Turbo + Stimulus) for interactive experience

## Prerequisites

- **Ruby**: 3.4.4 (via rbenv recommended)
- **Node**: 25.x (via nvm recommended)
- **Yarn**: 1.x

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd rock_paper_scissors
```

2. Install Ruby dependencies:
```bash
bundle install
```

3. Install JavaScript dependencies:
```bash
yarn install
```

4. Set up the database:
```bash
bin/rails db:prepare
```

## Running the Application

Start the development server:
```bash
bin/dev
```

Visit `http://localhost:3000` to play!

## How to Play

1. Choose your throw (Rock, Paper, Scissors, or Hammer)
2. Wait for the opponent's move from the API
3. See the result - Win, Lose, or Tie!
4. Click "Play Again" for another round

### Game Rules

Classic rules plus Hammer:

| Throw | Beats |
|-------|-------|
| Rock | Scissors |
| Paper | Rock, Hammer |
| Scissors | Paper |
| Hammer | Scissors, Rock |

## Running Tests

```bash
bundle exec rspec
```

## Architecture

### Domain Layer (`app/models/game/`)

- **`Throw`**: Value object representing a game throw with validation
- **`Rules`**: Registry defining what beats what (extensible)
- **`Resolver`**: Determines win/lose/tie using registry lookup

### Service Layer (`app/services/api/`)

- **`ThrowClient`**: HTTP client for external API with fallback

### Extensibility

Adding a new throw (e.g., "Spock") requires only:

1. Update `Game::Rules::RULES` hash:
```ruby
RULES = {
  rock: [:scissors, :spock],
  paper: [:rock],
  scissors: [:paper, :spock],
  hammer: [:scissors, :rock],
  spock: [:scissors, :rock]  # Spock beats scissors and rock
}.freeze
```

2. Add an icon partial at `app/views/games/icons/_spock.html.erb`

No changes needed to `Throw`, `Resolver`, or `GamesController`!

## API Integration

The application uses an external API for opponent throws:

- **Endpoint**: `GET https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw`
- **Timeout**: 5s connect, 10s read
- **Retries**: 1 retry on failure

When the API is unavailable, the game falls back to random local throws and indicates "offline mode" to the user.

## Tech Stack

- **Rails 8.x** - Web framework
- **Hotwire** - Turbo + Stimulus for interactivity
- **Tailwind CSS 4.x** - Styling
- **TypeScript** - Type-safe JavaScript
- **esbuild** - JavaScript bundling
- **RSpec** - Testing framework

## License

MIT
