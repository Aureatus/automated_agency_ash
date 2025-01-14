defmodule AutomatedAgency.Websites.UxAnalysis do
  use Ash.Resource,
    domain: AutomatedAgency.Websites,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :ux_analysis
    relationships [:ux_criticisms]

    mutations do
      action :create_ux_analysis_from_domain, :create_from_domain do
        error_location :in_result
      end
    end
  end

  postgres do
    table "ux_analyses"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id]

    create :create_with_criticisms do
      accept [:page_id]

      argument :ux_criticisms, {:array, :map},
        allow_nil?: false,
        constraints: [
          items: [
            fields: [
              severity: [
                type: :atom,
                constraints: [one_of: [:low, :medium, :high]],
                allow_nil?: false
              ],
              criticism: [type: :string, allow_nil?: false],
              explanation: [type: :string, allow_nil?: false]
            ]
          ]
        ]

      change manage_relationship(:ux_criticisms, type: :create)
    end

    action :create_from_domain do
      argument :domain_id, :uuid, allow_nil?: false

      returns :struct
      constraints instance_of: AutomatedAgency.Websites.Domain

      run AutomatedAgency.Websites.UxAnalysis.RunAnalysis
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :ux_criticisms, AutomatedAgency.Websites.UxCriticism, public?: true

    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false, public?: true
  end

  identities do
    identity :unique_on_page, [:page_id]
  end
end
