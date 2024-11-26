defmodule AutomatedAgency.Websites.Page do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "pages"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string, allow_nil?: false
    attribute :html, :string, allow_nil?: false
  end

  relationships do
    belongs_to :domain, AutomatedAgency.Websites.Domain, allow_nil?: false

    has_one :speed_analysis, AutomatedAgency.Websites.SpeedAnalysis, allow_nil?: false
    has_one :topic_analysis, AutomatedAgency.Websites.TopicAnalysis, allow_nil?: false
    has_one :ux_analysis, AutomatedAgency.Websites.UxAnalysis, allow_nil?: false
    has_one :improved_page, AutomatedAgency.Websites.ImprovedPage, allow_nil?: false
    has_one :screenshot, AutomatedAgency.Websites.Screenshot, allow_nil?: false
  end
end
