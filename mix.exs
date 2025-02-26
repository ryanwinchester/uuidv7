defmodule UUIDv7.MixProject do
  use Mix.Project

  @version "0.6.0"

  @repo_url "https://github.com/ryanwinchester/uuidv7"

  def project do
    [
      app: :uuid_v7,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @repo_url,
      homepage_url: @repo_url,
      name: "UUIDv7",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UUIDv7.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0", optional: true},
      {:uniq, "~> 0.1", only: [:bench], runtime: false},
      {:benchee, "~> 1.0", only: [:bench], runtime: false},
      {:ex_doc, "~> 0.31", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    UUID v7 with an 18-bit randomly-seeded counter.
    (Re: Section 6.2, from the IETF Draft.)
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url},
      maintainers: ["Ryan Winchester"]
    ]
  end

  defp docs do
    [
      main: "readme",
      api_reference: false,
      extras: ["README.md"],
      source_url: @repo_url,
      groups_for_docs: [
        Types: &(&1[:kind] == :type),
        "Ecto.Type Functions": fn fun ->
          fun[:group] == :ecto or fun[:name] in [:embed_as, :equal?]
        end,
        Functions: &(&1[:kind] == :function)
      ]
    ]
  end
end
