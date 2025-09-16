import { NextRequest, NextResponse } from "next/server";
import { getToken } from "next-auth/jwt";

export async function POST(request: NextRequest) {
  const token = await getToken({
    req: request,
    secret: process.env.NEXTAUTH_SECRET,
  });
  if (!token) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { text } = body;
    if (!text) {
      return NextResponse.json({ error: "Text is required." }, { status: 400 });
    }

    const apiResponse = await fetch(
      `${process.env.NEXT_PUBLIC_API_BASE_URL}/grammar/check`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token.accessToken}`,
        },
        body: JSON.stringify({ text }),
      }
    );

    const data = await apiResponse.json();
    if (!apiResponse.ok) {
      return NextResponse.json(
        { error: data.error || "Failed to check grammar." },
        { status: apiResponse.status }
      );
    }
    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error("Grammar check API error:", error);
    return NextResponse.json(
      { error: "An unexpected internal server error occurred." },
      { status: 500 }
    );
  }
}
