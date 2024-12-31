import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useState } from "react";

export const Route = createFileRoute("/")({
  component: SearchComponent,
});

function SearchComponent() {
  const [url, setUrl] = useState("");
  const navigate = useNavigate();

  const handleSubmit: React.FormEventHandler = (e) => {
    e.preventDefault();

    try {
      navigate({ to: "/analysis/" + encodeURIComponent(url) });
    } catch (error) {
      // Handle invalid URL error
      console.error("Invalid URL:", error);
    }
  };

  return (
    <div className="h-screen w-full flex items-center justify-center bg-background">
      <form onSubmit={handleSubmit} className="w-full max-w-xl space-y-4 px-4">
        <div className="relative flex flex-col items-center gap-8">
          <div className="relative w-full">
            <Input
              type="url"
              placeholder="Website to analyze..."
              className="w-full pl-10 h-12"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
            />
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          </div>
          <Button type="submit" className="w-2/3">
            Analyze
          </Button>
        </div>
      </form>
    </div>
  );
}

export default SearchComponent;
