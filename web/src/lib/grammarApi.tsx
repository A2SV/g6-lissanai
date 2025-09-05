export async function checkGrammar(text: string) {
  const res = await fetch("/api/grammar", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text }),
  });

  if (!res.ok) throw new Error("Grammar check failed");
  return res.json();
}
