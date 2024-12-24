defmodule AutomatedAgency.Websites do
  use Ash.Domain

  resources do
    resource AutomatedAgency.Websites.Domain do
      define :create_domain, action: :create, args: [:domain]
      define :setup_domain, action: :create_with_placeholder_pages, args: [:domain]
      define :populate_domain, action: :fetch_pages_content
    end

    resource AutomatedAgency.Websites.Page do
      define :create_page, action: :create, args: [:domain_id, :url, :html]
      define :create_page_from_url, action: :create_from_url, args: [:domain_id, :url]
    end

    resource AutomatedAgency.Websites.TopicAnalysis do
      define :create_topic_analysis, action: :create, args: [:page_id, :primary_category]
      define :create_topic_analysis_from_domain, action: :create_from_domain, args: [:domain_id]
    end

    resource AutomatedAgency.Websites.Keyword do
      define :create_topic_keyword, action: :create, args: [:topic_analysis_id, :keyword]
    end

    resource AutomatedAgency.Websites.UxAnalysis do
      define :create_ux_analysis, action: :create, args: [:page_id]
      define :create_ux_analysis_from_page, action: :create_from_page, args: [:page_id]
    end

    resource AutomatedAgency.Websites.UxCriticism do
      define :create_ux_criticism,
        action: :create,
        args: [:ux_analysis_id, :severity, :criticism, :explanation]
    end

    resource AutomatedAgency.Websites.SpeedAnalysis do
      define :create_speed_analysis,
        action: :create,
        args: [:page_id, :desktop_data, :mobile_data]

      define :create_speed_analysis_from_page, action: :create_from_page, args: [:page_id]
    end

    resource AutomatedAgency.Websites.ImprovedPage do
      define :create_improved_page, action: :create, args: [:page_id, :html]
      define :create_improved_page_for_existing_page, action: :create_for_page, args: [:page_id]
    end

    resource AutomatedAgency.Websites.Screenshot do
      define :create_screenshot, action: :create, args: [:page_id, :desktop_data, :mobile_data]
    end
  end
end
