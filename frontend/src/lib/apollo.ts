import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";

const httpLink = createHttpLink({
  // Proxy set in nginx.conf
  uri: "/gql/",
});

export const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
});
