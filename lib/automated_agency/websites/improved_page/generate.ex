defmodule AutomatedAgency.Websites.ImprovedPage.Generate do
  use Ash.Resource.Change
  use Ecto.Schema

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

  @primary_key false
  embedded_schema do
    field(:improved_html, :string)
    field(:improvements_made, {:array, :string})
  end

  def generate_html(
        html,
        topic_analysis,
        criticisms,
        desktop_screenshot,
        mobile_screenshot
      ) do
    base64_desktop_screenshot = "data:image/png;base64," <> Base.encode64(desktop_screenshot)
    base64_mobile_screenshot = "data:image/png;base64," <> Base.encode64(mobile_screenshot)

    keyword_list = parse_keyword_list(topic_analysis)
    criticism_list = parse_criticism_list(criticisms)

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
                     "I am going to provide two images,  one in desktop format, one in mobile format. I will also provide html of a site, alongside the main category, applicable keywords and some criticisms.
                      I would like you to create a new and improved site using html, and the improvements made.

                      The main category of this site is: #{topic_analysis.primary_category}, and
                      some keywords that are applicable for the site are: #{keyword_list}.

                      The criticisms are as follows:
                      #{criticism_list}

                      HTML: #{html}"
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

  defp parse_keyword_list(topic_analysis) do
    Enum.map(topic_analysis.keywords, & &1.keyword) |> Enum.join(", ")
  end

  defp parse_criticism_list(ux_criticisms) do
    Enum.with_index(ux_criticisms)
    |> Enum.map(&construct_criticism_line/1)
  end

  defp construct_criticism_line({
         criticism,
         index
       }) do
    "#{index + 1}. Severity: #{criticism.severity}, Summary: #{criticism.criticism}, More detailed explanation: #{criticism.explanation}"
  end
end
