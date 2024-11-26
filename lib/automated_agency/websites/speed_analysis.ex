defmodule AutomatedAgency.Websites.SpeedAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "speed_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :desktop_data, :map, allow_nil?: false
    attribute :mobile_data, :map, allow_nil?: false
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end
end
