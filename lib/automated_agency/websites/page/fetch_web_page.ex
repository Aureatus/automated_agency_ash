defmodule AutomatedAgency.Websites.Page.Fetch do
  use Ash.Resource.Change
  alias Wallaby.{Browser, WebdriverClient}
  alias AutomatedAgency.Websites.Screenshot.ImageOptimiser

  @desktop_width 1920
  @desktop_height 1080

  @mobile_width 360
  @mobile_height 800

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      url = Ash.Changeset.get_attribute(changeset, :url)

      {:ok, %{html: html, screenshots: screenshots}} =
        fetch_page_info(url)

      changeset
      |> Ash.Changeset.force_change_attribute(:html, html)
      |> Ash.Changeset.manage_relationship(
        :screenshot,
        %{
          desktop_data: screenshots.desktop_data,
          mobile_data: screenshots.mobile_data
        },
        type: :create
      )
    end)
  end

  defp fetch_page_info(url) do
    with {:ok, session} <- Wallaby.start_session(),
         session = Browser.visit(session, url),
         html = Browser.page_source(session),
         desktop_screenshot =
           get_screenshot(session, :desktop)
           |> ImageOptimiser.optimise_image(:desktop),
         mobile_screenshot =
           get_screenshot(session, :mobile)
           |> ImageOptimiser.optimise_image(:mobile),
         :ok <- Wallaby.end_session(session) do
      {:ok,
       %{
         html: html,
         screenshots: %{
           desktop_data: desktop_screenshot,
           mobile_data: mobile_screenshot
         }
       }}
    end
  end

  defp get_screenshot(session, form_factor) do
    case form_factor do
      :mobile -> Browser.resize_window(session, @mobile_width, @mobile_height)
      :desktop -> Browser.resize_window(session, @desktop_width, @desktop_height)
    end

    WebdriverClient.take_screenshot(session)
  end
end
