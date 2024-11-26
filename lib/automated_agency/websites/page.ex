defmodule AutomatedAgency.Websites.Page do
  use Ash.Resource, domain: AutomatedAgency.Websites

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string
    attribute :html, :string
  end

  relationships do
    belongs_to :domain, AutomatedAgency.Websites.Domain

    has_one :speed_analysis, AutomatedAgency.Websites.SpeedAnalysis
    has_one :topic_analysis, AutomatedAgency.Websites.TopicAnalysis
    has_one :ux_analysis, AutomatedAgency.Websites.UxAnalysis
    has_one :improved_page, AutomatedAgency.Websites.ImprovedPage
  end
end
