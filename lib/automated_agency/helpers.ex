defmodule AutomatedAgency.Helpers do
  def format_keywords_for_prompt(topic_analysis) do
    Enum.map(topic_analysis.keywords, & &1.keyword) |> Enum.join(", ")
  end
end
