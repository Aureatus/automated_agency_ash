defmodule AutomatedAgency.Websites.UxAnalysis.FetchAnalysis do
  use Ash.Resource.Change
  use Ecto.Schema

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      page_id = Ash.Changeset.get_attribute(changeset, :page_id)

      page =
        Ash.get!(AutomatedAgency.Websites.Page, page_id)
        |> Ash.load!([:screenshot, topic_analysis: [:keywords]])

      ux_analysis =
        generate_ux_insights(
          {page.screenshot.desktop_data, page.screenshot.mobile_data},
          page.topic_analysis
        )

      changeset
      |> Ash.Changeset.manage_relationship(
        :ux_criticisms,
        Enum.map(
          ux_analysis.points,
          &%{
            severity: &1.severity,
            criticism: &1.criticism,
            explanation: &1.explanation
          }
        ),
        type: :create
      )
    end)
  end

  @primary_key false
  embedded_schema do
    embeds_many :points, Point, primary_key: false do
      field(:severity, Ecto.Enum, values: [:low, :medium, :high])
      field(:criticism, :string)
      field(:explanation, :string)
    end
  end

  def generate_ux_insights(
        {desktop_screenshot, mobile_screenshot},
        topic_analysis
      ) do
    base64_desktop_screenshot = "data:image/png;base64," <> Base.encode64(desktop_screenshot)
    base64_mobile_screenshot = "data:image/png;base64," <> Base.encode64(mobile_screenshot)

    keyword_list = parse_keyword_list(topic_analysis)

    case Instructor.chat_completion(
           model: "gpt-4o-mini",
           response_model: __MODULE__,
           messages: [
             %{
               role: "user",
               content: [
                 %{
                   type: "text",
                   text:
                     "Can you provide some criticisms on the UI/UX design of this site, in the format of concise criticism + explanation + severity (of low, medium or high), and in order of importance?

                     The main category of this site is: #{topic_analysis.primary_category}.
                     Some keywords that are applicable for the site are: #{keyword_list}

                     There are two images provided, the larger one is a desktop format, the smaller is a mobile format."
                 },
                 %{type: "image_url", image_url: %{url: base64_desktop_screenshot}},
                 %{type: "image_url", image_url: %{url: base64_mobile_screenshot}}
               ]
             }
           ],
           max_tokens: 5000
         ) do
      {:ok, result} -> result
      {:error, error} -> error
    end
  end

  defp parse_keyword_list(topic_analysis) do
    Enum.map(topic_analysis.keywords, & &1.keyword) |> Enum.join(", ")
  end
end
