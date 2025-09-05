import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function Results({ analysis }: { analysis: any }) {
  const { issues, improvedText } = analysis;

  // Copy to clipboard
  const handleCopy = () => {
    navigator.clipboard.writeText(improvedText);
  };

  // Download as text file
  const handleDownload = () => {
    const blob = new Blob([improvedText], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "improved-text.txt";
    a.click();
    URL.revokeObjectURL(url);
  };

  if (!issues.length) {
    return (
      <Card className="p-4 mt-4">
        <h2 className="text-lg font-semibold text-green-600">
          ✅ Perfect Grammar!
        </h2>
        <p className="mt-2">{improvedText}</p>
        <div className="flex gap-2 mt-4">
          <Button onClick={handleCopy}>Copy</Button>
          <Button onClick={handleDownload}>Download</Button>
        </div>
      </Card>
    );
  }

  return (
    <div className="mt-4 space-y-4">
      <Card>
        <CardContent>
          <h2 className="text-lg font-semibold">Issues Found</h2>
          <ul className="mt-2 space-y-2">
            {issues.map((issue: any, i: number) => (
              <li key={i} className="p-2 rounded bg-red-50">
                <span className="font-bold">{issue.type}: </span>
                {issue.message}
                <div className="text-sm text-gray-600">
                  Suggestion: {issue.suggestion}
                </div>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <h2 className="text-lg font-semibold">Improved Version</h2>
          <p className="mt-2 whitespace-pre-line">{improvedText}</p>
          <div className="flex gap-2 mt-4">
            <Button onClick={handleCopy}>Copy</Button>
            <Button onClick={handleDownload}>Download</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
