import { useCallback, useEffect, useState } from "react";
import { createFileRoute, Link } from "@tanstack/react-router";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertCircle, Check, Loader2 } from "lucide-react";
import {
  useCreateTopicAnalysisFromDomainMutation,
  useCreateUxAnalysisFromDomainMutation,
  useGetDomainInfoQuery,
  usePopulateDomainMutation,
  useSetupDomainMutation,
} from "@/generated/graphql";

type SetupStage = {
  step: number;
  message: string;
} | null;

const LoadingState = () => (
  <div className="grid place-items-center min-h-screen">
    <div className="flex flex-col items-center space-y-8">
      <div className="relative">
        <Loader2 className="h-16 w-16 animate-spin text-primary" />
        <div className="absolute inset-0 h-16 w-16 animate-pulse bg-primary/5 rounded-full blur-xl" />
      </div>

      <div className="flex flex-col items-center gap-3">
        <p className="text-2xl font-medium text-primary">
          Loading domain information...
        </p>
        <p className="text-base text-muted-foreground">
          This may take a moment
        </p>
      </div>
    </div>
  </div>
);

const SetupState = ({ stage }: { stage: SetupStage }) => {
  if (!stage) return null;

  const steps = [
    "Domain Setup",
    "Page Analysis",
    "Content Analysis",
    "UX Analysis",
  ];

  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <Card className="w-full max-w-2xl bg-card/95 shadow-lg border-0">
        <CardContent className="space-y-6 p-8">
          <div className="flex items-center space-x-4 mb-8">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
            <p className="text-lg text-muted-foreground">{stage.message}</p>
          </div>

          {steps.map((step, index) => (
            <div key={index} className="flex items-center space-x-5">
              <div
                className={`h-12 w-12 rounded-full flex items-center justify-center text-base font-medium
                  ${
                    index + 1 === stage.step
                      ? "bg-primary text-primary-foreground"
                      : index + 1 < stage.step
                        ? "bg-primary/20 text-primary"
                        : "bg-muted/30 text-muted-foreground"
                  }`}
              >
                {index + 1 < stage.step ? (
                  <Check className="h-6 w-6" />
                ) : (
                  <span>{index + 1}</span>
                )}
              </div>
              <span
                className={`text-lg font-medium ${
                  index + 1 <= stage.step
                    ? "text-foreground"
                    : "text-muted-foreground"
                }`}
              >
                {step}
              </span>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
};
const ErrorState = ({ message }: { message: string }) => (
  <div className="grid place-items-center min-h-screen">
    <div className="flex flex-col items-center space-y-8">
      <div className="relative">
        <AlertCircle className="h-16 w-16 text-destructive" />
        <div className="absolute inset-0 h-16 w-16 animate-pulse bg-destructive/5 rounded-full blur-xl" />
      </div>

      <div className="flex flex-col items-center gap-3">
        <p className="text-2xl font-medium text-destructive">Error</p>
        <p className="text-base text-muted-foreground text-center max-w-md">
          {message}
        </p>
      </div>
    </div>
  </div>
);

function AnalysisComponent() {
  const { domain } = Route.useParams();
  const [isRunningFallback, setIsRunningFallback] = useState(false);
  const [setupStage, setSetupStage] = useState<SetupStage>(null);

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
      setSetupStage({
        step: 1,
        message: "Fetching initial domain information",
      });
      const result = await setupDomain({
        variables: { input: { domain: decodeURIComponent(domain) } },
      });
      const domainId = result.data?.setupDomain.result?.id;
      if (!domainId) throw new Error("Invalid domain id");

      setSetupStage({
        step: 2,
        message: "Capturing screenshots and analyzing pages",
      });
      await populateDomain({ variables: { input: { domainId } } });

      setSetupStage({ step: 3, message: "Analyzing content and topics" });
      await createTopicAnalysisFromDomain({
        variables: { input: { domainId } },
      });

      setSetupStage({ step: 4, message: "Generating UX insights" });
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
  if (setupStage) return <SetupState stage={setupStage} />;
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
