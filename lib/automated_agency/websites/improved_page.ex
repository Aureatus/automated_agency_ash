defmodule AutomatedAgency.Websites.ImprovedPage do
  use Ash.Resource, domain: AutomatedAgency.Websites, data_layer: AshPostgres.DataLayer

  postgres do
    table "improved_pages"
    repo AutomatedAgency.Repo
  end

  actions do
    defaults [:read]

    create :create, accept: [:page_id, :html]

    create :create_for_page do
      accept [:page_id]

      change AutomatedAgency.Websites.ImprovedPage.Generate
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :html, :string, allow_nil?: false
  end

  relationships do
    belongs_to :page, AutomatedAgency.Websites.Page, allow_nil?: false
  end
end
