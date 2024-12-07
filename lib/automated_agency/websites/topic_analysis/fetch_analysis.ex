defmodule AutomatedAgency.Websites.TopicAnalysis.FetchAnalysis do
  use Ash.Resource.Change
  use Ecto.Schema

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      page_id = Ash.Changeset.get_attribute(changeset, :page_id)
      page = Ash.get!(AutomatedAgency.Websites.Page, page_id)

      topic_analysis = get_topic_analysis_info(page.url, page.html)

      with_primary_category =
        changeset
        |> Ash.Changeset.force_change_attribute(
          :primary_category,
          topic_analysis.primary_category
        )

      IO.inspect(with_primary_category)

      Enum.reduce(topic_analysis.keywords, with_primary_category, fn keyword, acc ->
        Ash.Changeset.manage_relationship(
          acc,
          :keywords,
          %{
            keyword: keyword
          },
          type: :create
        )
      end)
    end)
  end

  @primary_key false
  embedded_schema do
    field(:primary_category, :string)
    field(:keywords, {:array, :string})
  end

  def get_topic_analysis_info(url, html) do
    page_info = get_key_text_from_html(html)

    {:ok, page_info} =
      Instructor.chat_completion(
        model: "gpt-4o-mini",
        response_model: __MODULE__,
        messages: [
          %{
            role: "user",
            content:
              "Extract a primary category for the following site using the url plus provided text, and a list of keywords that would be applicable.
                url: #{url}
                text: #{page_info}
                "
          }
        ]
      )

    page_info
  end

  defp get_key_text_from_html(html) do
    html |> HtmlEntities.decode() |> Readability.article() |> Readability.readable_text()
  end
end
