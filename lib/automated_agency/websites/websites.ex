defmodule AutomatedAgency.Websites do
  use Ash.Domain

  resources do
    resource AutomatedAgency.Websites.Domain
    resource AutomatedAgency.Websites.Page
    resource AutomatedAgency.Websites.TopicAnalysis
    resource AutomatedAgency.Websites.Keyword
    resource AutomatedAgency.Websites.UxAnalysis
    resource AutomatedAgency.Websites.UxCriticism
    resource AutomatedAgency.Websites.SpeedAnalysis
    resource AutomatedAgency.Websites.ImprovedPage
  end
end
