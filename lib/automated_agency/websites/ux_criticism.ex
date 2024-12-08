defmodule AutomatedAgency.Websites.UxCriticism do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "ux_criticisms"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:ux_analysis_id, :severity, :criticism, :explanation], primary?: true
  end

  attributes do
    uuid_primary_key :id

    attribute :severity, :atom, constraints: [one_of: [:low, :medium, :high]], allow_nil?: false
    attribute :criticism, :string, allow_nil?: false
    attribute :explanation, :string, allow_nil?: false
  end

  relationships do
    belongs_to :ux_analysis, AutomatedAgency.Websites.UxAnalysis, allow_nil?: false
  end

  identities do
    identity :unique_criticism, [:criticism, :ux_analysis_id]
  end
end
