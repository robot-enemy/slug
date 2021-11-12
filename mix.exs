defmodule Slug.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :slug,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # {:codepagex, github: "tallakt/codepagex"},
      # {:codepagex, github: "stubgun/codepagex"},
      {:codepagex, "~> 0.1.6"},
      {:ecto, "~> 3.2"},
      {:slugger, "~> 0.3"},
    ]
  end
end
