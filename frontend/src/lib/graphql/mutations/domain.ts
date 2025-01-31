import { gql } from "@apollo/client";

const SETUP_DOMAIN = gql`
  mutation setupDomain($input: SetupDomainInput!) {
    setupDomain(input: $input) {
      result {
        id
      }
      errors {
        code
        fields
        message
        shortMessage
        vars
      }
    }
  }
`;

const POPULATE_DOMAIN = gql`
  mutation populateDomain($input: PopulateDomainInput!) {
    populateDomain(input: $input) {
      result {
        domain
      }
      errors {
        code
        fields
        message
        shortMessage
        vars
      }
    }
  }
`;

const CREATE_TOPIC_ANALYSIS_FROM_DOMAIN = gql`
  mutation createTopicAnalysisFromDomain(
    $input: CreateTopicAnalysisFromDomainInput!
  ) {
    createTopicAnalysisFromDomain(input: $input) {
      result {
        domain
      }
      errors {
        code
        fields
        message
        shortMessage
        vars
      }
    }
  }
`;

const CREATE_UX_ANALYSIS_FROM_DOMAIN = gql`
  mutation createUxAnalysisFromDomain(
    $input: CreateUxAnalysisFromDomainInput!
  ) {
    createUxAnalysisFromDomain(input: $input) {
      result {
        domain
      }
      errors {
        code
        fields
        message
        shortMessage
        vars
      }
    }
  }
`;

export {
  SETUP_DOMAIN,
  POPULATE_DOMAIN,
  CREATE_TOPIC_ANALYSIS_FROM_DOMAIN,
  CREATE_UX_ANALYSIS_FROM_DOMAIN,
};
