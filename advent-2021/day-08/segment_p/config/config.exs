# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :segment_p,
  ecto_repos: [SegmentP.Repo]

# Configures the endpoint
config :segment_p, SegmentPWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "L1LMfXmIm5GxKOZwKcIkQTldfRB+bxn4Klp+Kaor45HZ2603A7qs7QPLOnYxCN4l",
  render_errors: [view: SegmentPWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SegmentP.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "OTbldWne"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
