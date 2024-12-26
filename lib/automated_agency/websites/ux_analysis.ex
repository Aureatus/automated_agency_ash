defmodule AutomatedAgency.Websites.UxAnalysis do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

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
      constraints instance_of: __MODULE__

      run AutomatedAgency.Websites.UxAnalysis.RunAnalysis
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    has_many :ux_criticisms, AutomatedAgency.Websites.UxCriticism

    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end

  identities do
    identity :unique_on_page, [:page_id]
  end
end
