import Config

if config_env() == :prod do
  database_url =
    "ecto://#{System.fetch_env!("DB_USER")}:#{System.fetch_env!("DB_PASSWORD")}@#{System.fetch_env!("DB_HOST")}/#{System.fetch_env!("DB_NAME")}"

  config :automated_agency, AutomatedAgency.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.fetch_env!("SECRET_KEY_BASE")

  host = System.fetch_env!("PHX_HOST")
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :automated_agency, AutomatedAgencyWeb.Endpoint,
    url: [host: host, port: 80],
    http: [
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true
end
