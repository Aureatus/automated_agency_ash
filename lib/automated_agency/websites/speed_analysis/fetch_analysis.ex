defmodule AutomatedAgency.Websites.SpeedAnalysis.FetchAnalysis do
  use Ash.Resource.Change

  @page_speed_url "https://www.googleapis.com/pagespeedonline/v5/runPagespeed"
  @page_speed_api_key System.get_env("GOOGLE_PAGESPEED_INSIGHTS_KEY")
  @formats [:desktop, :mobile]

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, fn changeset ->
      page_id = Ash.Changeset.get_attribute(changeset, :page_id)
      page = Ash.get!(AutomatedAgency.Websites.Page, page_id)

      [speed_analysis_desktop, speed_analysis_mobile] =
        @formats
        |> Task.async_stream(&get_page_speed_insights_data(page.url, &1), timeout: 20000)
        |> Enum.map(fn {:ok, result} -> result end)
        |> Enum.map(&parse_page_speed_insights_data/1)

      changeset
      |> Ash.Changeset.force_change_attribute(:desktop_data, speed_analysis_desktop)
      |> Ash.Changeset.force_change_attribute(:mobile_data, speed_analysis_mobile)
    end)
  end

  def get_page_speed_insights_data(target_url, form) do
    page_speed_insights =
      @page_speed_url
      |> Req.get!(
        params: [
          url: target_url,
          key: @page_speed_api_key,
          strategy: form,
          category: "ACCESSIBILITY",
          category: "BEST_PRACTICES",
          category: "PERFORMANCE",
          category: "SEO"
        ],
        receive_timeout: 20_000
      )

    page_speed_insights.body
  end

  @desired_web_vital_keys [
    :CUMULATIVE_LAYOUT_SHIFT_SCORE,
    :EXPERIMENTAL_TIME_TO_FIRST_BYTE,
    :FIRST_CONTENTFUL_PAINT_MS,
    :INTERACTION_TO_NEXT_PAINT,
    :LARGEST_CONTENTFUL_PAINT_MS
  ]

  @desired_lighthouse_keys [
    :accessibility,
    :"best-practices",
    :performance,
    :seo
  ]

  def parse_page_speed_insights_data(data) do
    core_web_vitals = Kernel.get_in(data, ["originLoadingExperience", "metrics"])
    lighthouse_data = Kernel.get_in(data, ["lighthouseResult", "categories"])

    core_web_vital_scores =
      core_web_vitals
      |> filter_unwanted_keys(@desired_web_vital_keys)
      |> Enum.map(fn {key, val} -> {String.to_existing_atom(key), val["category"]} end)
      |> Enum.into(%{})

    lighthouse_scores =
      lighthouse_data
      |> filter_unwanted_keys(@desired_lighthouse_keys)
      |> Enum.map(fn {key, val} -> {String.to_existing_atom(key), val["score"]} end)
      |> Enum.into(%{})

    IO.inspect(core_web_vital_scores)
    IO.inspect(lighthouse_scores)

    %{core_web_vital_scores: core_web_vital_scores, lighthouse_scores: lighthouse_scores}
  end

  defp filter_unwanted_keys(data, desired_keys) do
    stringified_keys = desired_keys |> Enum.map(&Atom.to_string/1)

    data
    |> Enum.filter(fn {key, _val} -> Enum.member?(stringified_keys, key) end)
  end
end
