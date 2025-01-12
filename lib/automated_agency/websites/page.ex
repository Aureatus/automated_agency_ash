defmodule AutomatedAgency.Websites.Page do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :page
    relationships [:topic_analysis, :ux_analysis, :improved_page]

    field_names base_page?: :is_base_page, content_fetched?: :is_content_fetched

    queries do
      get :fetch_page, :read, allow_nil?: false
    end
  end

  postgres do
    table "pages"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create,
      accept: [:domain_id, :url, :html, :base_page?, :content_fetched?],
      primary?: true

    create :create_from_url do
      accept [:domain_id, :url]
      # argument :domain_id, :uuid, allow_nil?: false
      # argument :url, :string, allow_nil?: false

      change AutomatedAgency.Websites.Page.Fetch
    end

    update :update, accept: [:html, :content_fetched?], primary?: true

    update :populate_page do
      accept [:html, :content_fetched?]

      argument :screenshot, :map,
        allow_nil?: false,
        constraints: [
          fields: [
            desktop_data: [type: :binary, allow_nil?: false],
            mobile_data: [type: :binary, allow_nil?: false]
          ]
        ]

      change manage_relationship(:screenshot, type: :create)

      require_atomic? false
    end
  end

  validations do
    validate present([:html]),
      where: attribute_equals(:content_fetched?, true)
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string, allow_nil?: false, public?: true
    attribute :html, :string, allow_nil?: true, public?: true

    attribute :base_page?, :boolean, allow_nil?: false, default: false, public?: true
    attribute :content_fetched?, :boolean, allow_nil?: false, default: false, public?: true
  end

  relationships do
    belongs_to :domain, AutomatedAgency.Websites.Domain, allow_nil?: false, public?: true

    has_one :speed_analysis, AutomatedAgency.Websites.SpeedAnalysis, allow_nil?: false

    has_one :topic_analysis, AutomatedAgency.Websites.TopicAnalysis,
      allow_nil?: false,
      public?: true

    has_one :ux_analysis, AutomatedAgency.Websites.UxAnalysis,
      allow_nil?: false,
      public?: true

    has_one :improved_page, AutomatedAgency.Websites.ImprovedPage,
      allow_nil?: false,
      public?: true

    has_one :screenshot, AutomatedAgency.Websites.Screenshot, allow_nil?: false
  end

  identities do
    identity :unique_url, [:url]
  end
end
