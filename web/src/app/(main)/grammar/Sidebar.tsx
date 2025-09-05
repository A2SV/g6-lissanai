import { Card, CardContent } from "@/components/ui/card";

export default function Sidebar({ analysis }: { analysis: any }) {
  return (
    <div className="space-y-4">
      <Card>
        <CardContent>
          <h3 className="font-bold">Your Grammar Coach</h3>
          <p className="text-sm text-gray-600">
            I’ll guide you step by step. Keep improving! 🚀
          </p>
        </CardContent>
      </Card>

      {analysis && (
        <Card>
          <CardContent>
            <h3 className="font-bold">Summary</h3>
            <ul className="mt-2 text-sm text-gray-700">
              <li>Score: {analysis.score}/100</li>
              <li>Issues: {analysis.issues.length}</li>
              <li>Words: {analysis.wordCount}</li>
              <li>Readability: {analysis.readability}</li>
            </ul>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardContent>
          <h3 className="font-bold">Writing Tips</h3>
          <ul className="mt-2 text-sm text-gray-700 list-disc pl-4">
            <li>Read aloud to catch errors</li>
            <li>Prefer active voice</li>
            <li>Keep sentences concise</li>
            <li>Check subject–verb agreement</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}
