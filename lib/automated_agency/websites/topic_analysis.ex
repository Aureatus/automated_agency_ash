defmodule AutomatedAgency.Websites.TopicAnalysis do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :topic_analysis
    relationships [:keywords]
  end

  postgres do
    table "topic_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id, :primary_category]

    create :create_with_keywords do
      accept [:page_id, :primary_category]

      argument :keywords, {:array, :map},
        allow_nil?: false,
        constraints: [
          items: [
            fields: [
              keyword: [type: :string, allow_nil?: false]
            ]
          ]
        ]

      change manage_relationship(:keywords, type: :create)
    end

    action :create_from_domain do
      argument :domain_id, :uuid, allow_nil?: false

      returns :struct
      constraints instance_of: __MODULE__

      run AutomatedAgency.Websites.TopicAnalysis.RunAnalysis
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :primary_category, :string, allow_nil?: false, public?: true
  end

  relationships do
    has_many :keywords, AutomatedAgency.Websites.Keyword, public?: true

    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false, public?: true
  end

  identities do
    identity :unique_on_page, [:page_id]
  end
end
