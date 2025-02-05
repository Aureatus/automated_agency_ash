# Use multi-stage build for smaller final image
FROM elixir:1.16-slim as builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends build-essential git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Copy compile-time config files
COPY config config
COPY priv priv

# Compile the release
COPY lib lib
RUN mix compile

# Generate release
RUN mix release

# Build runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/automated_agency ./

# Set default command
CMD ["/app/bin/automated_agency", "start"]