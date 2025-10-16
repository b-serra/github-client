defmodule GitHub.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/borja/github_client"

  def project do
    [
      app: :github_client,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "GitHub Client",
      source_url: @source_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.9"},
      {:jason, "~> 1.4"},
      {:hackney, "~> 1.20"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A comprehensive Elixir client for the GitHub REST API.
    Provides a simple, idiomatic interface to interact with GitHub's API
    using Tesla HTTP client with built-in authentication and error handling.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "GitHub",
      extras: ["README.md"]
    ]
  end
end
