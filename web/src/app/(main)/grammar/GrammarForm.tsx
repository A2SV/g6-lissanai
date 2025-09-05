"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { checkGrammar } from "@/lib/grammarApi";

export default function GrammarForm({
  onResult,
}: {
  onResult: (data: any) => void;
}) {
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit() {
    setLoading(true);
    const result = await checkGrammar(text);
    onResult(result);
    setLoading(false);
  }

  return (
    <div className="mb-6">
      <Textarea
        placeholder="Paste or type your text here..."
        rows={8}
        value={text}
        onChange={(e) => setText(e.target.value)}
      />
      <div className="flex justify-between mt-2">
        <span className="text-sm text-black">{text.length} characters</span>
        <Button onClick={handleSubmit} disabled={loading || !text}>
          {loading ? "Checking..." : "Check Grammar"}
        </Button>
      </div>
    </div>
  );
}
