use Mix.Config

# Configure your database
config :segment_p, SegmentP.Repo,
  username: "postgres",
  password: "postgres",
  database: "segment_p_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :segment_p, SegmentPWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
