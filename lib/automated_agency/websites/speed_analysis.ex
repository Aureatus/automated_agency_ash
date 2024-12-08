defmodule AutomatedAgency.Websites.SpeedAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "speed_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id, :desktop_data, :mobile_data]

    create :create_from_page do
      accept [:page_id]

      change AutomatedAgency.Websites.SpeedAnalysis.FetchAnalysis
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :desktop_data, :map, allow_nil?: false
    attribute :mobile_data, :map, allow_nil?: false
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end

  identities do
    identity :unique_on_page, [:page_id]
  end
end
