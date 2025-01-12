import { createFileRoute } from "@tanstack/react-router";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { AlertTriangle, AlertCircle, CheckCircle } from "lucide-react";
import { ReactElement } from "react";
import { useGetPageInfoQuery } from "@/generated/graphql";

type Keyword = {
  id: string;
  keyword: string;
};

type Criticism = {
  id: string;
  severity: string;
  criticism: string;
  explanation: string;
};

const IssueSection = ({
  icon,
  title,
  issues,
  variant,
  colorClasses,
}: {
  icon: ReactElement;
  title: string;
  issues: Criticism[];
  variant: "default" | "destructive" | null | undefined;
  colorClasses: string;
}) => (
  <div className={`rounded-lg p-6 ${colorClasses}`}>
    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
      {icon}
      {title}
    </h3>
    <div className="space-y-3">
      {issues.map((issue) => (
        <Alert
          key={issue.id}
          variant={variant}
          className="border-0 bg-white/90 dark:bg-gray-900/90"
        >
          <AlertDescription>
            <span className="font-medium text-base">{issue.criticism}</span>
            <p className="mt-2 text-sm opacity-90">{issue.explanation}</p>
          </AlertDescription>
        </Alert>
      ))}
    </div>
  </div>
);

function PageComponent() {
  const { pageId } = Route.useParams();

  const { loading, error, data } = useGetPageInfoQuery({
    variables: { id: pageId },
  });

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!data) return <div>No data received</div>;

  const page = data.fetchPage;

  const [highPrioIssues, mediumPrioIssues, lowPrioIssues] = [
    "high",
    "medium",
    "low",
  ].map((severity) =>
    page.uxAnalysis.uxCriticisms.filter(
      (criticism) => criticism.severity === severity
    )
  );

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-xl font-bold">Page Analysis</CardTitle>
          <CardDescription>
            <a
              href={page.url}
              className="text-blue-600 hover:underline break-all"
            >
              {page.url}
            </a>
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-2">
            <span className="font-medium">Primary Category:</span>
            <Badge variant="secondary">
              {page.topicAnalysis.primaryCategory}
            </Badge>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold">
            Topic Analysis
          </CardTitle>
          <CardDescription>
            Key topics and themes identified on the page
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {page.topicAnalysis.keywords.map(
              ({ id: id, keyword: keyword }: Keyword) => (
                <Badge variant="outline" key={id}>
                  {keyword}
                </Badge>
              )
            )}
          </div>
        </CardContent>
      </Card>

      {/* UX Analysis */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold">UX Analysis</CardTitle>
          <CardDescription>
            Identified UX issues and recommendations
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {highPrioIssues.length > 0 && (
            <IssueSection
              icon={
                <AlertTriangle className="h-6 w-6 text-red-500 dark:text-red-400" />
              }
              title="High Priority Issues"
              issues={highPrioIssues}
              variant="destructive"
              colorClasses="bg-red-50/50 dark:bg-red-950/50 border border-red-200 dark:border-red-900"
            />
          )}

          {mediumPrioIssues.length > 0 && (
            <IssueSection
              icon={
                <AlertCircle className="h-6 w-6 text-yellow-500 dark:text-yellow-400" />
              }
              title="Medium Priority Issues"
              issues={mediumPrioIssues}
              variant="default"
              colorClasses="bg-yellow-50/50 dark:bg-yellow-950/50 border border-yellow-200 dark:border-yellow-900"
            />
          )}

          {lowPrioIssues.length > 0 && (
            <IssueSection
              icon={
                <CheckCircle className="h-6 w-6 text-green-500 dark:text-green-400" />
              }
              title="Low Priority Issues"
              issues={lowPrioIssues}
              variant="default"
              colorClasses="bg-green-50/50 dark:bg-green-950/50 border border-green-200 dark:border-green-900"
            />
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export const Route = createFileRoute("/analysis/page/$pageId")({
  component: PageComponent,
});

export default PageComponent;
