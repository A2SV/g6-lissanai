
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

export async function POST(request: NextRequest) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });

  
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
  
    const body = await request.json();
    const { prompt, template_type, tone, type } = body;

  
    if (!prompt || !type) {
        return NextResponse.json({ error: 'Missing required fields: prompt and type are required.' }, { status: 400 });
    }

  
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/email/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
  
        'Authorization': `Bearer ${token.accessToken}`,
      },
      body: JSON.stringify({
        prompt,
        template_type,
        tone,
        type,
      }),
    });

  
    const data = await apiResponse.json();

    if (!apiResponse.ok) {
  
      return NextResponse.json(
        { error: data.error || 'Failed to process email request.' },
        { status: apiResponse.status }
      );
    }


    console.log("this is the data from the backend for email drafting",data);
  
    return NextResponse.json(data, { status: 200 });

  } catch (error) {
    console.error("Email drafting API error:", error);
    return NextResponse.json(
      { error: "An unexpected internal server error occurred." },
      { status: 500 }
    );
  }
}