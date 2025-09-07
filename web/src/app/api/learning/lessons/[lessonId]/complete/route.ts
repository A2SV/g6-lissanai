




import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';
/* eslint-disable @typescript-eslint/no-explicit-any */

interface Params {
  params: { lessonId: string };
}

export async function POST(request: NextRequest, { params }: Params) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { lessonId } = params;
  if (!lessonId) {
    return NextResponse.json({ error: 'Lesson ID is required.' }, { status: 400 });
  }

  try {
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/lessons/${lessonId}/complete`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token.accessToken}` },
    });

    if (!apiResponse.ok) {
      const data = await apiResponse.json();
      throw new Error(data.error || 'Failed to mark lesson as complete.');
    }
    
    const data = await apiResponse.json();
    return NextResponse.json(data);

  } catch (error: any) {
    console.error(`Complete Lesson (ID: ${lessonId}) API error:`, error.message);
    return NextResponse.json({ error: "An unexpected internal server error occurred." }, { status: 500 });
  }
}