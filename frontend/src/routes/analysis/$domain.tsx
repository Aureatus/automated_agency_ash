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
import { LoadingState } from "@/components/analysis/loading";
import { ErrorState } from "@/components/analysis/error";
import { SETUP_STEPS } from "@/lib/setup_steps";
import { SetupState } from "@/components/analysis/setup";

function AnalysisComponent() {
  const { domain } = Route.useParams();
  const [isRunningFallback, setIsRunningFallback] = useState(false);
  const [setupStage, setSetupStage] = useState<
    (typeof SETUP_STEPS)[number] | null
  >(null);

  const { loading, error, data, refetch } = useGetDomainInfoQuery({
    variables: { domain: decodeURIComponent(domain) },
  });

  const [setupDomain] = useSetupDomainMutation();
  const [populateDomain] = usePopulateDomainMutation();
  const [createTopicAnalysisFromDomain] =
    useCreateTopicAnalysisFromDomainMutation();
  const [createUxAnalysisFromDomain] = useCreateUxAnalysisFromDomainMutation();

  const handleFallbackProcess = useCallback(async () => {
    setIsRunningFallback(true);
    try {
      setSetupStage(SETUP_STEPS[0]);
      const result = await setupDomain({
        variables: { input: { domain: decodeURIComponent(domain) } },
      });
      const domainId = result.data?.setupDomain.result?.id;
      if (!domainId) throw new Error("Invalid domain id");

      setSetupStage(SETUP_STEPS[1]);
      await populateDomain({ variables: { input: { domainId } } });

      setSetupStage(SETUP_STEPS[2]);
      await createTopicAnalysisFromDomain({
        variables: { input: { domainId } },
      });

      setSetupStage(SETUP_STEPS[3]);
      await createUxAnalysisFromDomain({ variables: { input: { domainId } } });

      setSetupStage(null);
      await refetch();
    } catch (error) {
      console.error("Fallback process failed:", error);
      throw error;
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

  if (loading) return <LoadingState />;
  if (error) return <ErrorState message={error.message} />;
  if (setupStage) return <SetupState currentStage={setupStage} />;
  if (!data?.fetchDomain) return <ErrorState message="No data received" />;

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
