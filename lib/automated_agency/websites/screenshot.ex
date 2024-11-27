defmodule AutomatedAgency.Websites.Screenshot do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "screenshots"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id, :desktop_data, :mobile_data]
  end

  attributes do
    uuid_primary_key :id

    attribute :desktop_data, :string, allow_nil?: false
    attribute :mobile_data, :string, allow_nil?: false
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end
end
