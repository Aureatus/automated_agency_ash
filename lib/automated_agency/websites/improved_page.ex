defmodule AutomatedAgency.Websites.ImprovedPage do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :improved_page
  end

  postgres do
    table "improved_pages"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id, :html]

    action :create_from_domain do
      argument :domain_id, :uuid, allow_nil?: false

      returns :struct
      constraints instance_of: __MODULE__

      run AutomatedAgency.Websites.ImprovedPage.GenerateForDomain
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :html, :string, allow_nil?: false, public?: true
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false, public?: true
  end

  identities do
    identity :unique_on_page, [:page_id]
  end
end
