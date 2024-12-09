defmodule AutomatedAgency.Helpers do
  def prep_image_for_instructor(image) do
    "data:image/png;base64," <> Base.encode64(image)
  end

  def parse_keyword_list(topic_analysis) do
    Enum.map(topic_analysis.keywords, & &1.keyword) |> Enum.join(", ")
  end
end
