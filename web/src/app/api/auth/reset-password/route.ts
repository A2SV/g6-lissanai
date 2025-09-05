import { ResetPasswordSchema } from "@/app/lib/zod";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const body = await request.json();


    const { new_password, token } = body;
    const validationResult = ResetPasswordSchema.safeParse({
        new_password: body.new_password,
        confirmPassword: body.confirmPassword, 
    });

    if (!validationResult.success || !token) {
      return NextResponse.json({ message: "Invalid input." }, { status: 400 });
    }

    
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/reset-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        new_password, 
        token 
      })
    });

    const data = await apiResponse.json();

    if (!apiResponse.ok) {
      return NextResponse.json({ message: data.error || "Failed to reset password." }, { status: apiResponse.status });
    }

    return NextResponse.json({ message: "Password has been reset successfully." }, { status: 200 });

  } catch (error) {
    console.error("Reset Password API error:", error);
    return NextResponse.json({ message: "An unexpected error occurred." }, { status: 500 });
  }
}