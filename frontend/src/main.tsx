import ReactDOM from "react-dom/client";
import { RouterProvider, createRouter } from "@tanstack/react-router";

//theme provider
import { ThemeProvider } from "@/components/shared/ThemeProvider";
import { ApolloProvider } from "@apollo/client";
import { client } from "./lib/apollo";

// Import the generated route tree
import { routeTree } from "./routeTree.gen";

//global styles
import "./index.css";
import { StrictMode } from "react";

// Create a new router instance
const router = createRouter({ routeTree });

// Register the router instance for type safety
declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

// Render the app
const rootElement = document.getElementById("root")!;
if (!rootElement.innerHTML) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(
    <StrictMode>
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <ApolloProvider client={client}>
          <RouterProvider router={router} />
        </ApolloProvider>
      </ThemeProvider>
    </StrictMode>
  );
}
