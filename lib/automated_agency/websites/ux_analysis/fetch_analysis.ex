defmodule AutomatedAgency.Websites.UxAnalysis.FetchAnalysis do
  use Ash.Resource.Change
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts
  alias AutomatedAgency.Helpers

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

  def generate_ux_insights(
        {desktop_screenshot, mobile_screenshot},
        topic_analysis
      ) do
    base64_desktop_screenshot = Helpers.prep_image_for_instructor(desktop_screenshot)

    base64_mobile_screenshot = Helpers.prep_image_for_instructor(mobile_screenshot)

    keyword_list = Helpers.format_keywords_for_prompt(topic_analysis)

    prompt =
      AutomatedAgency.Websites.Prompts.build_ux_analysis_prompt(
        topic_analysis.primary_category,
        keyword_list
      )

    case Instructor.chat_completion(
           model: "gpt-4o-mini",
           response_model: Prompts.UxAnalysisResponseSchema,
           messages: [
             %{
               role: "user",
               content: [
                 %{
                   type: "text",
                   text: prompt
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
end
