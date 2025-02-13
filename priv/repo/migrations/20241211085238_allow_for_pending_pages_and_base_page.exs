defmodule AutomatedAgency.Repo.Migrations.AllowForPendingPagesAndBasePage do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:pages) do
      modify :html, :text, null: true
      add :base_page?, :boolean, null: false, default: false
      add :content_fetched?, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:pages) do
      remove :content_fetched?
      remove :base_page?
      modify :html, :text, null: false
    end
  end
end
