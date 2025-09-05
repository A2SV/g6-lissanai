
import { ForgotPasswordSchema } from "@/app/lib/zod";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    

    const validationResult = ForgotPasswordSchema.safeParse(body);
    if (!validationResult.success) {
      return NextResponse.json({ message: "Invalid email" }, { status: 400 });
    }

    
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/forgot-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: validationResult.data.email })
    });
    
    
    if (!apiResponse.ok) {
        console.error("Forgot password API failed, but sending generic response.");
        return NextResponse.json({ message: "If an account with that email exists, a password reset link has been sent." }, { status: 200 });
    }

    return NextResponse.json({ message: "If an account with that email exists, a password reset link has been sent." , apiResponse: apiResponse}, { status: 200 });

  } catch (error) {
    console.error("Forgot Password API error:", error);
    return NextResponse.json({ message: "An unexpected error occurred." }, { status: 500 });
  }
}