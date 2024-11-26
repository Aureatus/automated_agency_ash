defmodule AutomatedAgency.Websites.Domain do
  use Ash.Resource, domain: AutomatedAgency.Websites

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :domain, :string
  end

  relationships do
    has_many :pages, AutomatedAgency.Websites.Page
  end
end
