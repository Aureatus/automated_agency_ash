defmodule AutomatedAgency.Websites.TopicAnalysis.FetchAnalysis do
  alias AutomatedAgency.Websites.Prompts
  use Ash.Resource.Change
  use Ecto.Schema

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      page_id = Ash.Changeset.get_attribute(changeset, :page_id)
      %{url: url, html: html} = Ash.get!(AutomatedAgency.Websites.Page, page_id)

      %{primary_category: primary_category, keywords: keywords} =
        generate_topic_analysis(url, html)

      changeset
      |> Ash.Changeset.force_change_attribute(
        :primary_category,
        primary_category
      )
      |> Ash.Changeset.manage_relationship(
        :keywords,
        Enum.map(keywords, &%{keyword: &1}),
        type: :create
      )
    end)
  end

  def generate_topic_analysis(url, html) do
    page_info = extract_key_text_from_html(html)

    prompt =
      AutomatedAgency.Websites.Prompts.build_topic_analysis_prompt(url, page_info)

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
