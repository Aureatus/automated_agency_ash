defmodule AutomatedAgency.Websites.TopicAnalysis.FetchAnalysis do
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

  @primary_key false
  embedded_schema do
    field(:primary_category, :string)
    field(:keywords, {:array, :string})
  end

  def generate_topic_analysis(url, html) do
    page_info = extract_key_text_from_html(html)

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

  defp extract_key_text_from_html(html) do
    html |> HtmlEntities.decode() |> Readability.article() |> Readability.readable_text()
  end
end
