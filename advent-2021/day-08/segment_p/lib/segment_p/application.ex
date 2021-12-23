defmodule SegmentP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      SegmentP.Repo,
      # Start the endpoint when the application starts
      SegmentPWeb.Endpoint
      # Starts a worker by calling: SegmentP.Worker.start_link(arg)
      # {SegmentP.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SegmentP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SegmentPWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
