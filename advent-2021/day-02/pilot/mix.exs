defmodule Pilot.MixProject do
  use Mix.Project

  def project do
    [
      app: :pilot,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:submarine, path: "../../submarine"},
    ]
  end

  defp escript_config do
    [
      main_module: Pilot
    ]
  end
end
