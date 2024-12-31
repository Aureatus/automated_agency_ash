import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery, gql } from "@apollo/client";

import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

const GET_DOMAIN_WITH_ALL_INFO = gql`
  query ($domain: String!) {
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

function AnalysisComponent() {
  const { domain } = Route.useParams();

  const { loading, error, data } = useQuery(GET_DOMAIN_WITH_ALL_INFO, {
    variables: { domain: decodeURIComponent(domain) },
  });

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  const { pages } = data.fetchDomain;

  return (
    <div>
      <h1>Analyzing domain: {domain}</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
        {pages.map((page: { id: string; isBasePage: boolean; url: string }) => (
          <Card key={page.id} className="h-full">
            <CardContent className="flex flex-col items-center justify-center p-6">
              <div className="flex items-center gap-2 mb-4">
                {page.isBasePage && (
                  <Badge variant="secondary">Base Page</Badge>
                )}
              </div>
              <Link to="/analysis/page/$pageId" params={{ pageId: page.id }}>
                {page.url}
              </Link>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}

export const Route = createFileRoute("/analysis/$domain")({
  component: AnalysisComponent,
});

export default AnalysisComponent;
