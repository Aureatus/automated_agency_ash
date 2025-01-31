import { Loader2 } from "lucide-react";

export const LoadingState = () => (
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
