defmodule AiValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :ai_validator,
      version: "0.1.0",
      elixir: "~> 1.17",
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

  # Run "mix help compile.app" to learn about applications.
  defp deps do
  [
    {:plug_cowboy, "~> 2.6"},
    {:jason, "~> 1.4"},
    {:httpoison, "~> 2.0"}
  ]
end
end
