defmodule AutomatedAgency.Websites.TopicAnalysis.RunAnalysis do
  use Ash.Resource.Actions.Implementation
  use Ecto.Schema
  alias AutomatedAgency.Websites.Prompts

  def run(input, _opts, _arg2) do
    domain = Ash.get!(AutomatedAgency.Websites.Domain, input.arguments.domain_id)
    domain_with_pages = Ash.load!(domain, :pages)

    topic_analyses =
      Task.async_stream(domain_with_pages.pages, fn %{url: url, html: html, id: id} ->
        topic_analysis = generate_topic_analysis(url, html)

        %{
          primary_category: topic_analysis.primary_category,
          keywords: Enum.map(topic_analysis.keywords, &%{keyword: &1}),
          page_id: id
        }
      end)
      |> Enum.map(fn {:ok, val} -> val end)

    _records =
      Ash.bulk_create!(
        topic_analyses,
        AutomatedAgency.Websites.TopicAnalysis,
        :create_with_keywords,
        return_records?: true,
        return_errors?: true
      )

    domain_with_pages_and_topic_analyses =
      Ash.load!(domain, pages: [topic_analysis: [:keywords]])

    {:ok, domain_with_pages_and_topic_analyses}
  end

  defp generate_topic_analysis(url, html) do
    page_info = extract_key_text_from_html(html)

    prompt =
      Prompts.build_topic_analysis_prompt(url, page_info)

    {:ok, page_info} =
      Instructor.chat_completion(
        model: "gpt-4o-mini",
        response_model: Prompts.TopicAnalysisResponseSchema,
        messages: [
          %{
            role: "user",
            content: prompt
          }
        ]
      )

    page_info
  end

  defp extract_key_text_from_html(html) do
    html |> HtmlEntities.decode() |> Readability.article() |> Readability.readable_text()
  end
end
