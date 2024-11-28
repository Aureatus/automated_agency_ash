defmodule ActionInvocationTest do
  # use ExUnit.Case
  use AutomatedAgency.DataCase
  import ExUnitProperties
  alias AutomatedAgency.Websites

  describe "Whole flow valid" do
    property "Create all records in order successfully" do
      domain = Websites.create_domain!("test.com")
      page = Websites.create_page!(domain.id, "test.com/page1", "<div>Some test html!!!</div>")
      screenshots = Websites.create_screenshot!(page.id, "img_data_1", "img_data_2")
      speed_analysis = Websites.create_speed_analysis!(page.id, %{test: 1}, %{test: 2})

      topic_analysis = Websites.create_topic_analysis!(page.id, "E-commerce")
      keywords = Websites.create_topic_keyword!(topic_analysis.id, "books")

      ux_analysis = Websites.create_ux_analysis!(page.id)

      ux_criticisms =
        Websites.create_ux_criticism!(
          ux_analysis.id,
          :high,
          "Bad contrast",
          "Lack of contrasting colors affects accessibility negatively"
        )

      improved_page = Websites.create_improved_page!(page.id, "<div>Some improved html!!!</div>")

      domain_with_relations =
        domain
        |> Ash.load!(
          pages: [
            :screenshot,
            :speed_analysis,
            :improved_page,
            topic_analysis: [:keywords],
            ux_analysis: [:ux_criticisms]
          ]
        )
    end
  end
end

ExUnit.run()
