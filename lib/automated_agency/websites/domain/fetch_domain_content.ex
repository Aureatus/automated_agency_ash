defmodule AutomatedAgency.Websites.Domain.FetchDomainContent do
  use Ash.Resource.Actions.Implementation
  alias Wallaby.{Browser, WebdriverClient}

  @desktop_width 1920
  @desktop_height 1080

  @mobile_width 360
  @mobile_height 800

  def run(input, _opts, _arg2) do
    domain = Ash.get!(AutomatedAgency.Websites.Domain, input.arguments.domain_id)
    domain_with_pages = Ash.load!(domain, :pages)

    pages_with_html =
      Task.async_stream(domain_with_pages.pages, fn page ->
        page_info = fetch_page_info(page.url)

        page_with_html =
          %{html: page_info.html, content_fetched?: true, screenshot: page_info.screenshots}

        {page, page_with_html}
      end)
      |> Enum.map(fn {:ok, val} -> val end)

    pages_with_html
    |> Enum.each(fn {page, page_with_html} ->
      Ash.update!(page, page_with_html, action: :populate_page)
    end)

    domain_with_updated_pages =
      Ash.load!(domain, :pages)

    {:ok, domain_with_updated_pages}
  end

  defp fetch_page_info(url) do
    with {:ok, session} <- Wallaby.start_session(),
         session = Browser.visit(session, url),
         html = Browser.page_source(session),
         desktop_screenshot = get_screenshot(session, :desktop),
         mobile_screenshot = get_screenshot(session, :mobile),
         :ok <- Wallaby.end_session(session) do
      %{
        html: html,
        screenshots: %{
          desktop_data: desktop_screenshot,
          mobile_data: mobile_screenshot
        }
      }
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
