import { gql } from "@apollo/client";

export const GET_PAGE_WITH_ALL_INFO = gql`
  query GetPageInfo($id: ID!) {
    fetchPage(id: $id) {
      url
      isBasePage
      isContentFetched
      html
      topicAnalysis {
        primaryCategory
        keywords {
          id
          keyword
        }
      }
      uxAnalysis {
        uxCriticisms {
          id
          severity
          criticism
          explanation
        }
      }
    }
  }
`;
