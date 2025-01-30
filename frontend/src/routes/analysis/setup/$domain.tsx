import { ErrorState } from "@/components/analysis/error";
import { SetupState } from "@/components/analysis/setup";
import {
  GetDomainInfoDocument,
  useCreateTopicAnalysisFromDomainMutation,
  useCreateUxAnalysisFromDomainMutation,
  usePopulateDomainMutation,
  useSetupDomainMutation,
} from "@/generated/graphql";
import { SETUP_STEPS } from "@/lib/setup_steps";
import { createFileRoute, Link } from "@tanstack/react-router";
import { useCallback, useEffect, useRef, useState } from "react";
import { client } from "../../../lib/apollo";

function SetupComponent() {
  const { domain } = Route.useParams();
  const [setupStage, setSetupStage] = useState<(typeof SETUP_STEPS)[number]>(
    SETUP_STEPS[0]
  );
  const [setupComplete, setSetupComplete] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const setupInProgress = useRef(false);

  const [setupDomain] = useSetupDomainMutation();
  const [populateDomain] = usePopulateDomainMutation();
  const [createTopicAnalysisFromDomain] =
    useCreateTopicAnalysisFromDomainMutation();
  const [createUxAnalysisFromDomain] = useCreateUxAnalysisFromDomainMutation();

  const runSetup = useCallback(async () => {
    if (setupInProgress.current) {
      return;
    }

    setupInProgress.current = true;

    try {
      const result = await setupDomain({
        variables: { input: { domain: decodeURIComponent(domain) } },
      });

      const domainId = result.data?.setupDomain.result?.id;
      if (!domainId) throw new Error("Invalid domain id");

      setSetupStage(SETUP_STEPS[1]);
      await populateDomain({
        variables: { input: { domainId } },
      });

      setSetupStage(SETUP_STEPS[2]);
      await createTopicAnalysisFromDomain({
        variables: { input: { domainId } },
      });

      setSetupStage(SETUP_STEPS[3]);
      await createUxAnalysisFromDomain({
        variables: { input: { domainId } },
      });

      await client.refetchQueries({
        include: [GetDomainInfoDocument],
        updateCache(cache) {
          cache.evict({ fieldName: "getDomainInfo" });
          cache.gc();
        },
      });

      setSetupComplete(true);
    } catch (err) {
      console.error("Setup process failed:", err);
      setError(
        err instanceof Error ? err : new Error("Unknown error occurred")
      );
    } finally {
      setupInProgress.current = false;
    }
  }, [
    createTopicAnalysisFromDomain,
    createUxAnalysisFromDomain,
    domain,
    populateDomain,
    setupDomain,
  ]);

  useEffect(() => {
    let mounted = true;

    const execute = async () => {
      if (mounted && !setupComplete && !error) {
        await runSetup();
      }
    };

    execute();

    return () => {
      mounted = false;
    };
  }, [runSetup, setupComplete, error]);

  if (error) return <ErrorState message={error.message} />;

  return (
    <SetupState currentStage={setupStage} complete={setupComplete}>
      <Link
        to="/analysis/$domain"
        params={{ domain }}
        className="relative z-10 after:absolute after:inset-0 after:bg-gradient-to-r after:from-transparent after:via-white/20 after:to-transparent after:-translate-x-full hover:after:translate-x-full after:transition-transform after:duration-1000"
      >
        Go to Overview
      </Link>
    </SetupState>
  );
}

export const Route = createFileRoute("/analysis/setup/$domain")({
  component: SetupComponent,
});

export default SetupComponent;
