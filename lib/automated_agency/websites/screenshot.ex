defmodule AutomatedAgency.Websites.Screenshot do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "screenshots"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :desktop_data, :string
    attribute :mobile_data, :string
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page
  end
end
