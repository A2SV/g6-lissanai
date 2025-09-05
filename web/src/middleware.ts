
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { getToken } from 'next-auth/jwt';

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  console.log('--- Middleware running for path:', pathname, '---');

  const secret = process.env.NEXTAUTH_SECRET;
  if (!secret) {
    console.error('CRITICAL: NEXTAUTH_SECRET is not set in the environment!');
  }

  const token = await getToken({ req, secret });
  console.log('Token found:', token ? `User: ${token.accessToken}` : 'No token');

  const protectedRoutes = ['/learn', '/grammar','interview','writing'];
  const authRoutes = ['/login', '/signup', '/forgot-password', '/reset-password'];

  const isProtectedRoute = protectedRoutes.some(path => pathname.startsWith(path));
  const isAuthRoute = authRoutes.some(path => pathname.startsWith(path));

  if (!token && isProtectedRoute) {
    console.log('Redirecting unauthenticated user to /login');
    const signInUrl = new URL('/login', req.url);
    signInUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(signInUrl);
  }

  if (token && isAuthRoute) {
    console.log('Redirecting authenticated user to /learn');
    return NextResponse.redirect(new URL('/learn', req.url));
  }

  console.log('Allowing request to proceed.');
  return NextResponse.next();
}

export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};