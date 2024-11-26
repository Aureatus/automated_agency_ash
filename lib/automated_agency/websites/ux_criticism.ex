defmodule AutomatedAgency.Websites.UxCriticism do
  use Ash.Resource, domain: AutomatedAgency.Websites

  actions do
    defaults [:read]

    create :create
  end

  attributes do
    uuid_primary_key :id

    attribute :severity, :atom, constraints: [one_of: [:low, :medium, :high]]
    attribute :criticism, :string
    attribute :explanation, :string
  end

  relationships do
    belongs_to :ux_analysis, AutomatedAgency.Websites.UxAnalysis
  end
end
