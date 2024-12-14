defmodule AutomatedAgency.Websites.Domain.SetupDomain do
  use Ash.Resource.Change
  alias AutomatedAgency.Websites.Prompts
  alias Wallaby.{Browser}

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      domain_url = Ash.Changeset.get_attribute(changeset, :domain)

      base_html = fetch_page_info(domain_url)

      page_urls =
        extract_internal_links(domain_url, base_html) |> filter_relevant_links(base_html)

      base_page = %{url: domain_url, base_page?: true}

      placeholder_pages = Enum.map(page_urls, &%{url: &1})

      changeset
      |> Ash.Changeset.manage_relationship(
        :pages,
        [base_page] ++ placeholder_pages,
        type: :create
      )
    end)
  end

  defp fetch_page_info(url) do
    with {:ok, session} <- Wallaby.start_session(),
         session = Browser.visit(session, url),
         html = Browser.page_source(session),
         :ok <- Wallaby.end_session(session) do
      html
    end
  end

  defp extract_internal_links(html, base_url) do
    base_uri = URI.parse(base_url)

    {:ok, parsed_html} = Floki.parse_document(html)

    parsed_html
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.uniq()
    |> Enum.map(&URI.merge(base_uri, &1))
    |> Enum.map(&URI.to_string/1)
    |> Enum.filter(fn url ->
      URI.parse(url).host == base_uri.host
    end)
  end

  defp filter_relevant_links(
         urls,
         html
       ) do
    formatted_urls = Prompts.format_url_list_for_prompt(urls)

    prompt =
      Prompts.build_relevant_links_prompt(
        html,
        formatted_urls
      )

    case Instructor.chat_completion(
           model: "gpt-4o-mini",
           response_model: Prompts.RelevantLinksResponseSchema,
           messages: [
             %{
               role: "user",
               content: [
                 %{
                   type: "text",
                   text: prompt
                 }
               ]
             }
           ],
           max_tokens: 5000
         ) do
      {:ok, result} -> result.urls
      {:error, error} -> error
    end
  end
end
