defmodule AutomatedAgency.Websites.TopicAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "topic_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :primary_category, :string
  end

  relationships do
    has_many :keywords, AutomatedAgency.Websites.Keyword

    belongs_to :page, AutomatedAgency.Websites.Page
  end
end
