
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

export async function POST(request: NextRequest) {
  // 1. Authenticate the user
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    // 2. Get the multipart form data from the incoming request
    const formData = await request.formData();
    const audio_data = formData.get('audio_data');
    const target_text = formData.get('target_text');

    // Basic validation
    if (!audio_data || !target_text) {
      return NextResponse.json({ error: 'Missing audio_data or target_text.' }, { status: 400 });
    }
    
    // 3. Create a new FormData object to forward to the backend
    // This is necessary because we can't directly forward the original request's body
    const backendFormData = new FormData();
    backendFormData.append('audio_data', audio_data);
    backendFormData.append('target_text', target_text.toString());

    // 4. Securely call the backend API with the form data
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/pronunciation/assess`, {
      method: 'POST',
      headers: {
        // IMPORTANT: Do not set the 'Content-Type' header yourself.
        // The browser will automatically set it to 'multipart/form-data' with the correct boundary.
        'Authorization': `Bearer ${token.accessToken}`,
      },
      body: backendFormData,
    });

    // 5. Handle the response from the backend
    const data = await apiResponse.json();

    if (!apiResponse.ok) {
      return NextResponse.json(
        { error: data.error || 'Failed to assess pronunciation.' },
        { status: apiResponse.status }
      );
    }
    
    // 6. Send the successful assessment feedback back to the frontend
    return NextResponse.json(data, { status: 200 });

  } catch (error) {
    console.error("Assess Pronunciation API error:", error);
    return NextResponse.json(
      { error: "An unexpected internal server error occurred." },
      { status: 500 }
    );
  }
}