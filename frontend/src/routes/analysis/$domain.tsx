import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useGetDomainInfoQuery } from "@/generated/graphql";
import { LoadingState } from "@/components/analysis/loading";
import { ErrorState } from "@/components/analysis/error";

function AnalysisComponent() {
  const { domain } = Route.useParams();

  const { loading, error, data } = useGetDomainInfoQuery({
    variables: { domain: decodeURIComponent(domain) },
  });

  if (loading) return <LoadingState />;
  if (error) return <ErrorState message={error.message} />;
  if (!data?.fetchDomain)
    return (
      <Navigate from={Route.fullPath} to="/analysis/setup/$domain" params />
    );

  const pages = data.fetchDomain?.pages;

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
