defmodule AutomatedAgency.Websites.UxAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "ux_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id]
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :ux_criticisms, AutomatedAgency.Websites.UxCriticism

    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end
end
