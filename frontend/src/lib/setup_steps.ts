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
