defmodule AutomatedAgency.Websites.Page.FetchWebPage do
  use Ash.Resource.Change

  @desktop_width 1920
  @desktop_height 1080

  @mobile_width 360
  @mobile_height 800

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      IO.inspect(changeset)
      {:ok, page_info} = Ash.Changeset.get_attribute(changeset, :url) |> fetch()

      changeset
      |> Ash.Changeset.force_change_attribute(:html, page_info.html)
      |> Ash.Changeset.manage_relationship(
        :screenshot,
        %{
          desktop_data: page_info.screenshots.desktop_data,
          mobile_data: page_info.screenshots.mobile_data
        },
        type: :create
      )
    end)
  end

  defp get_dimensions(session) do
    session
    |> Wallaby.Browser.find(Wallaby.Query.css("html"))
    |> Wallaby.Element.size()
  end

  defp get_screenshot(session, form_factor) do
    case form_factor do
      :mobile -> Wallaby.Browser.resize_window(session, @mobile_width, @mobile_height)
      :desktop -> Wallaby.Browser.resize_window(session, @desktop_width, @desktop_height)
    end

    {current_width, current_height} = get_dimensions(session)

    Wallaby.Browser.resize_window(session, current_width, current_height)

    screenshot = Wallaby.WebdriverClient.take_screenshot(session)
    screenshot
  end

  def fetch(url) do
    case Wallaby.start_session() do
      {:ok, session} ->
        session = Wallaby.Browser.visit(session, url)
        html = Wallaby.Browser.page_source(session)

        desktop_screenshot = get_screenshot(session, :desktop)
        mobile_screenshot = get_screenshot(session, :mobile)

        :ok = Wallaby.end_session(session)

        {:ok,
         %{
           html: html,
           screenshots: %{
             desktop_data: desktop_screenshot,
             mobile_data: mobile_screenshot
           }
         }}

      {:error, err} ->
        {:error, err}
    end
  end
end
