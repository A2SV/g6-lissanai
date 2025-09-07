



import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';


interface Params {
  params: { quizId: string };
}
/* eslint-disable @typescript-eslint/no-explicit-any */

export async function POST(request: NextRequest, { params }: Params) {
    

  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  
  const { quizId } = params;
  if (!quizId) {
    return NextResponse.json({ error: 'Quiz ID is required.' }, { status: 400 });
  }
  
  
  try {
    const body = await request.json();
    const { answers } = body;

    if (!answers) {
      return NextResponse.json({ error: 'Answers are required.' }, { status: 400 });
    }

    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/quizzes/${quizId}/submit`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token.accessToken}`,
      },
      body: JSON.stringify({
        quiz_id: quizId,
        answers: answers,
      }),
    });

    const data = await apiResponse.json();
    if (!apiResponse.ok) {
      throw new Error(data.error || 'Failed to submit quiz.');
    }
    return NextResponse.json(data);

  } catch (error: any) {
    console.error(`Submit Quiz (ID: ${quizId}) API error:`, error.message);
    return NextResponse.json({ error: "An unexpected internal server error occurred." }, { status: 500 });
  }
}