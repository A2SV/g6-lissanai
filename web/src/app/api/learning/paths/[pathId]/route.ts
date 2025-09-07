

import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';
import type { NextRequest } from 'next/server';

interface Params {
  params: { pathId: string };
}
/* eslint-disable @typescript-eslint/no-explicit-any */

export async function GET(request: NextRequest, { params }: Params) {
  const token = await getToken({ req: request, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { pathId } = params;
  if (!pathId) {
    return NextResponse.json({ error: 'Path ID is required.' }, { status: 400 });
  }

  try {
    
    const apiResponse = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/learning/paths`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token.accessToken}` },
    });
    
    if (!apiResponse.ok) {
      const errorData = await apiResponse.json();
      throw new Error(errorData.error || 'Failed to fetch learning paths.');
    }

    const allPaths: any[] = await apiResponse.json();

    
    const singlePath = allPaths.find(p => p.id === pathId);

    if (!singlePath) {
      return NextResponse.json({ error: 'Learning path not found.' }, { status: 404 });
    }

    
    return NextResponse.json(singlePath, { status: 200 });

  } catch (error: any) {
    console.error(`Get Path by ID (ID: ${pathId}) API error:`, error.message);
    return NextResponse.json({ error: "An unexpected internal server error occurred." }, { status: 500 });
  }
}