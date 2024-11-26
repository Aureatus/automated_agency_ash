defmodule AutomatedAgency.Repo do
  use Ecto.Repo,
    otp_app: :automated_agency,
    adapter: Ecto.Adapters.Postgres
end
