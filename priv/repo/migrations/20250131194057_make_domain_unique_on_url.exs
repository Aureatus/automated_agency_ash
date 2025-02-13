defmodule AutomatedAgency.Repo.Migrations.MakeDomainUniqueOnUrl do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(:domains, [:domain], name: "domains_unique_domain_index")
  end

  def down do
    drop_if_exists unique_index(:domains, [:domain], name: "domains_unique_domain_index")
  end
end
