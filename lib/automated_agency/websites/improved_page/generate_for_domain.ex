defmodule AutomatedAgency.Websites.ImprovedPage.GenerateForDomain do
  use Ash.Resource.Actions.Implementation
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts

  def run(input, _opts, _arg2) do
    domain = Ash.get!(AutomatedAgency.Websites.Domain, input.arguments.domain_id)

    enriched_domain =
      Ash.load!(domain,
        pages: [:screenshot, topic_analysis: [:keywords], ux_analysis: [:ux_criticisms]]
      )

    improved_pages =
      Task.async_stream(
        enriched_domain.pages,
        fn page ->
          improved_page =
            generate_html(
              page.html,
              page.topic_analysis,
              page.ux_analysis.ux_criticisms,
              page.screenshot.desktop_data,
              page.screenshot.mobile_data
            )

          %{
            page_id: page.id,
            html: improved_page.improved_html
          }
        end,
        timeout: 50000
      )
      |> Enum.map(fn {:ok, val} -> val end)

    _records =
      Ash.bulk_create!(
        improved_pages,
        AutomatedAgency.Websites.ImprovedPage,
        :create,
        return_records?: true,
        return_errors?: true
      )

    domain_with_ux_analyses =
      Ash.load!(domain, pages: [ux_analysis: [:ux_criticisms]])

    {:ok, domain_with_ux_analyses}
  end

  defp generate_html(
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
        html,
        topic_analysis.primary_category,
        keyword_list,
        criticism_list
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
