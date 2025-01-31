import { useCallback, useEffect, useRef, useState } from "react";
import {
  GetDomainInfoDocument,
  useSetupDomainMutation,
  usePopulateDomainMutation,
  useCreateTopicAnalysisFromDomainMutation,
  useCreateUxAnalysisFromDomainMutation,
} from "@/generated/graphql";
import { client } from "../lib/apollo";

export const SETUP_STEPS = [
  {
    step: 1,
    label: "Domain Setup",
    message: "Fetching initial domain information",
  },
  {
    step: 2,
    label: "Page Analysis",
    message: "Capturing screenshots and analyzing pages",
  },
  {
    step: 3,
    label: "Content Analysis",
    message: "Analyzing content and topics",
  },
  { step: 4, label: "UX Analysis", message: "Generating UX insights" },
] as const;

export function useSetupDomain(domain: string) {
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

  return { setupStage, setupComplete, error };
}
