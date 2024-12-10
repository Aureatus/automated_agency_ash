defmodule AutomatedAgency.Websites.Prompts do
  @topic_analysis """
  Extract a primary category for the following site using the url plus provided text, and a list of keywords that would be applicable.
  url: {{url}}
  text: {{page_info}}
  """

  @ux_analysis """
  Can you provide some criticisms on the UI/UX design of this site,
  in the format of concise criticism + explanation + severity (of low, medium or high),
  and in order of importance?

  The main category of this site is: {{primary_category}}.
  Some keywords that are applicable for the site are: {{keywords}}

  There are two images provided, the larger one is a desktop format, the smaller is a mobile format.
  """

  @improved_page """
  I am going to provide two images, one in desktop format, one in mobile format.
  I will also provide html of a site, alongside the main category, applicable keywords and some criticisms.

  I would like you to create a new and improved site using html, and the improvements made.

  The main category of this site is: {{primary_category}}.
  Some keywords that are applicable for the site are: {{keywords}}.

  The criticisms are as follows:
  {{criticisms}}

  The HTML is: {{html}}
  """

  defmodule TopicAnalysisResponseSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:primary_category, :string)
      field(:keywords, {:array, :string})
    end
  end

  defmodule UxAnalysisResponseSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      embeds_many :points, Point, primary_key: false do
        field(:severity, Ecto.Enum, values: [:low, :medium, :high])
        field(:criticism, :string)
        field(:explanation, :string)
      end
    end
  end

  defmodule ImprovedPageResponseSchema do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:improved_html, :string)
      field(:improvements_made, {:array, :string})
    end
  end

  def build_topic_analysis_prompt(url, page_info) do
    @topic_analysis
    |> String.replace("{{url}}", url)
    |> String.replace("{{page_info}}", page_info)
  end

  def build_ux_analysis_prompt(primary_category, keywords) do
    @ux_analysis
    |> String.replace("{{primary_category}}", primary_category)
    |> String.replace("{{keywords}}", keywords)
  end

  def build_improved_page_prompt(primary_category, keywords, criticisms, html) do
    @improved_page
    |> String.replace("{{primary_category}}", primary_category)
    |> String.replace("{{keywords}}", keywords)
    |> String.replace("{{criticisms}}", criticisms)
    |> String.replace("{{html}}", html)
  end

  def format_image_for_api(image) do
    data_url = "data:image/png;base64," <> Base.encode64(image)
    %{type: "image_url", image_url: %{url: data_url}}
  end

  def format_keywords_for_prompt(topic_analysis) do
    Enum.map(topic_analysis.keywords, & &1.keyword) |> Enum.join(", ")
  end
end
