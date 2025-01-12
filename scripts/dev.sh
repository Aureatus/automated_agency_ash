#!/bin/bash

echo "Starting development environment..."

# Function for cleanup operations
cleanup() {
    echo "Cleaning up..."
    docker compose down
    pkill -f "iex -S mix"
    pkill -f "vite"
    pkill -f "npm run dev"
    pkill -f "chokidar"
    tmux kill-session -t dev
}

# Register cleanup function to run on script exit
trap cleanup EXIT

# Initial cleanup
echo "Cleaning up previous instances..."
docker compose down 2>/dev/null || true
pkill -f "iex -S mix" || true
pkill -f "vite" || true
pkill -f "npm run dev" || true
pkill -f "chokidar" || true
tmux kill-session -t dev 2>/dev/null || true

# Initial generation
echo "Generating GraphQL schema..."
mix ash.codegen priv/schema.graphql
echo "Generating frontend types..."
cd frontend && npm run codegen && cd ..

# Start watchers in the background
echo "Starting schema watcher..."
npx chokidar-cli "lib/**/*.{ex,exs}" -c "mix ash.codegen priv/schema.graphql"

echo "Starting frontend types watcher..."
npx chokidar-cli "priv/schema.graphql" -c "cd frontend && npm run codegen"

# Create and attach to session with mouse mode enabled
tmux new-session -s dev \; \
  set -g mouse on \; \
  set-option remain-on-exit off \; \
  set-option destroy-unattached on \; \
  split-window -h \; \
  select-pane -t 0 \; \
  split-window -v \; \
  select-pane -t 0 \; \
  send-keys 'docker compose up; tmux kill-session -t dev' Enter \; \
  select-pane -t 1 \; \
  send-keys 'export $(cat .env | sed "/^#/d") && iex -S mix phx.server; tmux kill-session -t dev' Enter \; \
  select-pane -t 2 \; \
  send-keys 'cd frontend && npm run dev; tmux kill-session -t dev' Enter