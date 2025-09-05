import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  console.log('Token found from get sentence api:', token?.accessToken);
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {

    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/pronunciation/sentence`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token.accessToken}`,
      },
    });


    const data = await apiResponse.json();
    console.log(' this is the Get Sentence API response:', data);

    if (!apiResponse.ok) {
      return NextResponse.json(
        { error: data.error || 'Failed to fetch practice sentence.' },
        { status: apiResponse.status }
      );
    }

   
    
    return NextResponse.json(data, { status: 200 });

  } catch (error) {
    console.error("Get Sentence API error:", error);
    return NextResponse.json(
      { error: "An unexpected internal server error occurred." },
      { status: 500 }
    );
  }
}