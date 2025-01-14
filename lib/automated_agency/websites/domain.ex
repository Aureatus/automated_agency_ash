defmodule AutomatedAgency.Websites.Domain do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :domain
    relationships [:pages]

    queries do
      read_one :fetch_domain, :read_by_domain
    end

    mutations do
      create :setup_domain, :create_with_placeholder_pages

      action :populate_domain, :fetch_pages_content_for_domain do
        error_location :in_result
      end
    end
  end

  postgres do
    table "domains"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    read :read_by_domain do
      get_by :domain
    end

    create :create, accept: [:domain]

    create :create_with_placeholder_pages do
      accept [:domain]

      change AutomatedAgency.Websites.Domain.SetupDomain
    end

    update :fetch_pages_content do
      change AutomatedAgency.Websites.Domain.PopulatePages
      require_atomic? false
    end

    action :fetch_pages_content_for_domain, :struct do
      argument :domain_id, :uuid, allow_nil?: false

      constraints instance_of: __MODULE__

      run AutomatedAgency.Websites.Domain.FetchDomainContent

      transaction? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :domain, :string, allow_nil?: false, public?: true
  end

  relationships do
    has_many :pages, AutomatedAgency.Websites.Page, public?: true
  end
end
