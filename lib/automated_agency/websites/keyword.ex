defmodule AutomatedAgency.Websites.Keyword do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :keywords
  end

  postgres do
    table "keywords"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:topic_analysis_id, :keyword], primary?: true
  end

  attributes do
    uuid_primary_key :id

    attribute :keyword, :string, allow_nil?: false, public?: true
  end

  relationships do
    belongs_to :topic_analysis, AutomatedAgency.Websites.TopicAnalysis,
      allow_nil?: false,
      public?: true
  end

  identities do
    identity :unique_keyword, [:keyword, :topic_analysis_id]
  end
end
