defmodule CryptoRand.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_rand,
      version: "1.0.2",
      elixir: "~> 1.8",
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  defp deps,
    do: [
      {:earmark, "~> 1.3", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]

  defp description do
    """
    Fast and efficient cryptographically strong versions of several Enum functions that rely on :rand uniform functions for randomness.
    """
  end

  defp package do
    [
      maintainers: ["Paul Rogers"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/CryptoRand/Elixir",
        "README" => "https://cryptorand.github.io/Elixir/",
        "Docs" => "https://hexdocs.pm/crypto_rand/api-reference.html"
      }
    ]
  end
end
