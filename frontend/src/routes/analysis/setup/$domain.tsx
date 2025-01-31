import { createFileRoute, Link } from "@tanstack/react-router";

import { useSetupDomain } from "@/lib/useSetupDomain";
import { ErrorState } from "@/components/analysis/error";
import { SetupState } from "@/components/analysis/setup";

function SetupComponent() {
  const { domain } = Route.useParams();
  const { setupStage, setupComplete, error } = useSetupDomain(domain);

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
