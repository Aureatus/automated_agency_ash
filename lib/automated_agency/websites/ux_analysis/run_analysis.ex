defmodule AutomatedAgency.Websites.UxAnalysis.RunAnalysis do
  use Ash.Resource.Actions.Implementation
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts

  def run(input, _opts, _arg2) do
    domain = Ash.get!(AutomatedAgency.Websites.Domain, input.arguments.domain_id)
    enriched_domain = Ash.load!(domain, pages: [:screenshot, topic_analysis: [:keywords]])

    IO.inspect(enriched_domain)

    ux_analyses =
      Task.async_stream(
        enriched_domain.pages,
        fn page ->
          ux_analysis =
            generate_ux_insights(
              {page.screenshot.desktop_data, page.screenshot.mobile_data},
              page.topic_analysis
            )

          %{
            page_id: page.id,
            ux_criticisms:
              Enum.map(
                ux_analysis.points,
                &%{
                  severity: &1.severity,
                  criticism: &1.criticism,
                  explanation: &1.explanation
                }
              )
          }
        end,
        timeout: 30000
      )
      |> Enum.map(fn {:ok, val} -> val end)

    _records =
      Ash.bulk_create!(
        ux_analyses,
        AutomatedAgency.Websites.UxAnalysis,
        :create_with_criticisms,
        return_records?: true,
        return_errors?: true
      )

    domain_with_ux_analyses =
      Ash.load!(domain, pages: [ux_analysis: [:ux_criticisms]])

    {:ok, domain_with_ux_analyses}
  end

  def generate_ux_insights(
        {desktop_screenshot, mobile_screenshot},
        topic_analysis
      ) do
    desktop_image_prompt = Prompts.format_image_for_api(desktop_screenshot)
    mobile_image_prompt = Prompts.format_image_for_api(mobile_screenshot)

    keyword_list = Prompts.format_keywords_for_prompt(topic_analysis)

    prompt =
      Prompts.build_ux_analysis_prompt(
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
                 desktop_image_prompt,
                 mobile_image_prompt
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
