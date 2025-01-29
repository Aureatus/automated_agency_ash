import { SETUP_STEPS } from "@/lib/setup_steps";
import { Loader2, Check } from "lucide-react";
import { Card, CardContent } from "../ui/card";

export const SetupState = ({
  currentStage,
}: {
  currentStage: (typeof SETUP_STEPS)[number];
}) => {
  if (!currentStage) return null;

  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <Card className="w-full max-w-2xl bg-card/95 shadow-lg border-0">
        <CardContent className="space-y-6 p-8">
          <div className="flex items-center space-x-4 mb-8">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
            <p className="text-lg text-muted-foreground">
              {currentStage.message}
            </p>
          </div>

          {SETUP_STEPS.map(({ step, label }, index) => (
            <div key={index} className="flex items-center space-x-5">
              <div
                className={`h-12 w-12 rounded-full flex items-center justify-center text-base font-medium
                    ${
                      step === currentStage.step
                        ? "bg-primary text-primary-foreground"
                        : step < currentStage.step
                          ? "bg-primary/20 text-primary"
                          : "bg-muted/30 text-muted-foreground"
                    }`}
              >
                {step < currentStage.step ? (
                  <Check className="h-6 w-6" />
                ) : (
                  <span>{step}</span>
                )}
              </div>
              <span
                className={`text-lg font-medium ${
                  step <= currentStage.step
                    ? "text-foreground"
                    : "text-muted-foreground"
                }`}
              >
                {label}
              </span>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
};
