defmodule AutomatedAgency.Websites.UxAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :ux_criticisms, AutomatedAgency.Websites.UxCriticism

    belongs_to :page, AutomatedAgency.Websites.Page
  end
end
