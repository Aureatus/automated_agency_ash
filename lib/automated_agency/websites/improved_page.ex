defmodule AutomatedAgency.Websites.ImprovedPage do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "improved_pages"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :html, :string
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page
  end
end
