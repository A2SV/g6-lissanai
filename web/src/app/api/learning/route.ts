
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

/* eslint-disable @typescript-eslint/no-explicit-any */

export async function GET(request: NextRequest) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/paths`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token.accessToken}` },
    });

    const data = await apiResponse.json();
    if (!apiResponse.ok) {
      throw new Error(data.error || 'Failed to fetch learning paths.');
    }
    return NextResponse.json(data, { status: 200 });
  } catch (error: any) {
    console.error("Get All Paths API error:", error.message);
    return NextResponse.json({ error: "An unexpected error occurred." }, { status: 500 });
  }
}