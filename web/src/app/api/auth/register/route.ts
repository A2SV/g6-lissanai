
import { SignUpSchema } from "@/app/lib/zod";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const body = await request.json();


    const validationResult = SignUpSchema.safeParse(body);
    if (!validationResult.success) {
      return NextResponse.json(
        { message: "Invalid input", errors: validationResult.error.flatten().fieldErrors },
        { status: 400 }
      );
    }

    const { fullName, email, password } = validationResult.data;

    
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: fullName, 
        email: email,
        password: password
      })
    });

    
    const data = await apiResponse.json();

    if (!apiResponse.ok) {
    
      return NextResponse.json(
        { message: data.error || 'Registration failed' },
        { status: apiResponse.status }
      );
    }


    console.log("Registration API response:", data);
      return NextResponse.json(
      { message: "User registered successfully", user: data.user },
      { status: 201 }
    );

  } catch (error) {
    console.error("Registration API error:", error);
    return NextResponse.json(
      { message: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}