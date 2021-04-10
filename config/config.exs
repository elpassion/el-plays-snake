# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :el_plays_snake,
  ecto_repos: [ElPlaysSnake.Repo]

# Configures the endpoint
config :el_plays_snake, ElPlaysSnakeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kYVUJlvmRo03wJSjsZy2b0xSFQWXa4+id67Fs/yMHTbi4ZXD7OPrRTDUrp9M1f7T",
  render_errors: [view: ElPlaysSnakeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ElPlaysSnake.PubSub,
  live_view: [signing_salt: "iro/LWhV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
