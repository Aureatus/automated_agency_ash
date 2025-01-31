import { AlertCircle } from "lucide-react";

export const ErrorState = ({ message }: { message: string }) => (
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
