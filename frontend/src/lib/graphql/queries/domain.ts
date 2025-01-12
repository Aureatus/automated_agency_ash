import { gql } from "@apollo/client";

export const GET_DOMAIN_WITH_ALL_INFO = gql`
  query GetDomainInfo($domain: String!) {
    fetchDomain(domain: $domain) {
      id
      domain
      pages {
        id
        url
        isBasePage
        isContentFetched
        html
        topicAnalysis {
          primaryCategory
          keywords {
            keyword
          }
        }
        uxAnalysis {
          uxCriticisms {
            severity
            criticism
            explanation
          }
        }
        improvedPage {
          html
        }
      }
    }
  }
`;
