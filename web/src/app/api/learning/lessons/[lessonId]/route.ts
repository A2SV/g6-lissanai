
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

interface Params {
  params: { lessonId: string };
}

export async function GET(request: NextRequest, { params }: Params) {

  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { lessonId } = params;
  if (!lessonId) {
    return NextResponse.json({ error: 'Lesson ID is required.' }, { status: 400 });
  }

  try {
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/lessons/${lessonId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token.accessToken}`,
      },
    });

    
    const data = await apiResponse.json();

    if (!apiResponse.ok) {
      
      return NextResponse.json(
        { error: data.error || 'Failed to fetch lesson content.' },
        { status: apiResponse.status }
      );
    }

    
    return NextResponse.json(data, { status: 200 });

  } catch (error) {
    console.error(`Get Lesson (ID: ${lessonId}) API error:`, error);
    return NextResponse.json(
      { error: "An unexpected internal server error occurred." },
      { status: 500 }
    );
  }
}