import { createFileRoute } from "@tanstack/react-router";

function AnalysisComponent() {
  const { domain } = Route.useParams();
  return <div>Analyzing domain: {domain}</div>;
}

export const Route = createFileRoute("/analysis/$domain")({
  component: AnalysisComponent,
});

export default AnalysisComponent;
