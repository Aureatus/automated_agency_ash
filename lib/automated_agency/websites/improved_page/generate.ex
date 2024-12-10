defmodule AutomatedAgency.Websites.ImprovedPage.Generate do
  use Ash.Resource.Change
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts
  alias AutomatedAgency.Helpers

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      page_id = Ash.Changeset.get_attribute(changeset, :page_id)

      page =
        Ash.get!(AutomatedAgency.Websites.Page, page_id)
        |> Ash.load!([:screenshot, topic_analysis: [:keywords], ux_analysis: [:ux_criticisms]])

      improved_page =
        generate_html(
          page.html,
          page.topic_analysis,
          page.ux_analysis.ux_criticisms,
          page.screenshot.desktop_data,
          page.screenshot.mobile_data
        )

      changeset
      |> Ash.Changeset.force_change_attribute(
        :html,
        improved_page.improved_html
      )
    end)
  end

  def generate_html(
        html,
        topic_analysis,
        criticisms,
        desktop_screenshot,
        mobile_screenshot
      ) do
    base64_desktop_screenshot = Helpers.prep_image_for_instructor(desktop_screenshot)

    base64_mobile_screenshot = Helpers.prep_image_for_instructor(mobile_screenshot)

    keyword_list = Helpers.format_keywords_for_prompt(topic_analysis)
    criticism_list = parse_criticism_list(criticisms)

    prompt =
      Prompts.build_improved_page_prompt(
        topic_analysis.primary_category,
        keyword_list,
        criticism_list,
        html
      )

    case Instructor.chat_completion(
           model: "gpt-4o-mini",
           response_model: Prompts.ImprovedPageResponseSchema,
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
           max_tokens: 15000
         ) do
      {:ok, result} -> result
      {:error, error} -> error
    end
  end

  defp parse_criticism_list(ux_criticisms) do
    Enum.with_index(ux_criticisms)
    |> Enum.map(&construct_criticism_line/1)
    |> Enum.join("\n")
  end

  defp construct_criticism_line({
         criticism,
         index
       }) do
    "#{index + 1}. Severity: #{criticism.severity}, Summary: #{criticism.criticism}, More detailed explanation: #{criticism.explanation}"
  end
end
