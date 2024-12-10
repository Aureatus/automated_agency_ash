defmodule AutomatedAgency.Websites.ImprovedPage.Generate do
  use Ash.Resource.Change
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts

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
    desktop_image_prompt = Prompts.format_image_for_api(desktop_screenshot)
    mobile_image_prompt = Prompts.format_image_for_api(mobile_screenshot)

    keyword_list = Prompts.format_keywords_for_prompt(topic_analysis)
    criticism_list = Prompts.format_criticism_list_for_prompt(criticisms)

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
                 desktop_image_prompt,
                 mobile_image_prompt
               ]
             }
           ],
           max_tokens: 15000
         ) do
      {:ok, result} -> result
      {:error, error} -> error
    end
  end
end
