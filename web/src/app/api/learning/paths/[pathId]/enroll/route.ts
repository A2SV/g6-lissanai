


import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

interface Params {
  params: { pathId: string };
}
/* eslint-disable @typescript-eslint/no-explicit-any */

export async function POST(request: NextRequest, { params }: Params) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { pathId } = params;
  if (!pathId) {
    return NextResponse.json({ error: 'Path ID is required.' }, { status: 400 });
  }
  try {
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/paths/${pathId}/enroll`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token.accessToken}`,
      },
      body: JSON.stringify({}),
    });
    if (!apiResponse.ok) {
      const errorData = await apiResponse.json();
      throw new Error(errorData.error || 'Failed to enroll.');
    }
    const data = await apiResponse.json();
    return NextResponse.json(data);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}