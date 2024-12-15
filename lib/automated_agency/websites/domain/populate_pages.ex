defmodule AutomatedAgency.Websites.Domain.PopulatePages do
  use Ash.Resource.Change
  alias Wallaby.{Browser}

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      domain =
        changeset.data
        |> Ash.load!([:pages])

      pages_with_html =
        domain.pages
        |> Enum.map(fn page ->
          Task.async(fn ->
            %{page | html: fetch_page_info(page.url), content_fetched?: true} |> Map.from_struct()
          end)
        end)
        |> Task.await_many()

      IO.inspect(pages_with_html |> Enum.at(0))

      changeset
      |> Ash.Changeset.manage_relationship(
        :pages,
        pages_with_html,
        on_match: :update
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
end
