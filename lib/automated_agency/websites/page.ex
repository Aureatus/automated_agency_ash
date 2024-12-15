defmodule AutomatedAgency.Websites.Page do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

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
  end

  validations do
    validate present([:html]),
      where: attribute_equals(:content_fetched?, true)
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string, allow_nil?: false
    attribute :html, :string, allow_nil?: true

    attribute :base_page?, :boolean, allow_nil?: false, default: false
    attribute :content_fetched?, :boolean, allow_nil?: false, default: false
  end

  relationships do
    belongs_to :domain, AutomatedAgency.Websites.Domain, allow_nil?: false

    has_one :speed_analysis, AutomatedAgency.Websites.SpeedAnalysis, allow_nil?: false
    has_one :topic_analysis, AutomatedAgency.Websites.TopicAnalysis, allow_nil?: false
    has_one :ux_analysis, AutomatedAgency.Websites.UxAnalysis, allow_nil?: false
    has_one :improved_page, AutomatedAgency.Websites.ImprovedPage, allow_nil?: false
    has_one :screenshot, AutomatedAgency.Websites.Screenshot, allow_nil?: false
  end

  identities do
    identity :unique_url, [:url]
  end
end
