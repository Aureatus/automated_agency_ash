import { useCallback, useEffect, useState } from "react";
import { createFileRoute, Link } from "@tanstack/react-router";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  useCreateTopicAnalysisFromDomainMutation,
  useCreateUxAnalysisFromDomainMutation,
  useGetDomainInfoQuery,
  usePopulateDomainMutation,
  useSetupDomainMutation,
} from "@/generated/graphql";

function AnalysisComponent() {
  const { domain } = Route.useParams();

  const [isRunningFallback, setIsRunningFallback] = useState(false);

  const { loading, error, data, refetch } = useGetDomainInfoQuery({
    variables: { domain: decodeURIComponent(domain) },
  });
  const [setupStage, setSetupStage] = useState<string | null>(null);

  const [setupDomain] = useSetupDomainMutation();
  const [populateDomain] = usePopulateDomainMutation();
  const [createTopicAnalysisFromDomain] =
    useCreateTopicAnalysisFromDomainMutation();
  const [createUxAnalysisFromDomain] = useCreateUxAnalysisFromDomainMutation();

  const handleFallbackProcess = useCallback(async () => {
    setIsRunningFallback(true);
    try {
      setSetupStage("Fetching initial domain information");
      const result = await setupDomain({
        variables: { input: { domain: decodeURIComponent(domain) } },
      });
      const domainId = result.data?.setupDomain.result?.id;
      if (!domainId) throw new Error("Invalid domain id");
      setSetupStage("Snapping screenshots...");
      await populateDomain({ variables: { input: { domainId } } });
      setSetupStage("Generating Topic Analyses...");
      await createTopicAnalysisFromDomain({
        variables: { input: { domainId } },
      });
      setSetupStage("Generating UX Insights...");
      await createUxAnalysisFromDomain({ variables: { input: { domainId } } });

      // Refetch the query after all mutations are done
      setSetupStage(null);
      await refetch();
    } catch (error) {
      console.error("Fallback process failed:", error);
    } finally {
      setIsRunningFallback(false);
    }
  }, [
    domain,
    setupDomain,
    populateDomain,
    createTopicAnalysisFromDomain,
    createUxAnalysisFromDomain,
    refetch,
  ]);

  useEffect(() => {
    if (!loading && !error && !data?.fetchDomain && !isRunningFallback) {
      handleFallbackProcess();
    }
  }, [loading, error, data, isRunningFallback, handleFallbackProcess]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (setupStage)
    return (
      <div>
        Setting up page, current step:
        <br></br>
        {setupStage}
      </div>
    );
  if (!data?.fetchDomain) return <div>No data received</div>;

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
