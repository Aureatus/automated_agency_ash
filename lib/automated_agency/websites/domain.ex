defmodule AutomatedAgency.Websites.Domain do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "domains"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:domain]
  end

  attributes do
    uuid_primary_key :id

    attribute :domain, :string, allow_nil?: false
  end

  relationships do
    has_many :pages, AutomatedAgency.Websites.Page
  end
end
