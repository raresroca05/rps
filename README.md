# Rock Paper Scissors

A web-based application that allows a user to play Rock-Paper-Scissors against a server API.

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

| Throw    | Beats    |
|----------|----------|
| Rock     | Scissors |
| Paper    | Rock     |
| Scissors | Paper    |

Identical throws result in a tie.

## Running Tests

```bash
bundle exec rspec
```

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

## Architecture

### Domain Layer (`app/models/game/`)

- **`Throw`**: Value object with validation against allowed throws
- **`Rules`**: Registry defining what beats what (extensible)
- **`Resolver`**: Determines win/lose/tie using registry lookup

### Service Layer (`app/services/api/`)

- **`ThrowClient`**: HTTP client with timeout, retry, and local fallback

## Tech Stack

- **Rails 8** - Modern Ruby web framework
- **Hotwire (Turbo + Stimulus)** - SPA-like interactivity without heavy JavaScript
- **Tailwind CSS 4** - Utility-first styling matching the mockup
- **TypeScript** - Type-safe JavaScript for Stimulus controllers
- **RSpec** - Testing framework with WebMock for API mocking
