defmodule AutomatedAgency.Websites.Keyword do
  use Ash.Resource, domain: AutomatedAgency.Websites

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :keyword, :string
  end

  relationships do
    belongs_to :topic_analysis, AutomatedAgency.Websites.TopicAnalysis
  end
end
