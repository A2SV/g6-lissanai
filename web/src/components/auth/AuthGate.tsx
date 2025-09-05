
"use client";

import { useEffect } from "react";
import { useSession, signOut } from "next-auth/react";
import { useAppDispatch, useAppSelector } from "@/app/lib/redux/hooks";
import { logout, setCredentials } from "@/app/lib/redux/slices/authSlice";

export default function AuthGate({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const dispatch = useAppDispatch();
  const { isAuthenticated } = useAppSelector((state) => state.auth);

  useEffect(() => {
    if (status === "loading") {
      
      return;
    }

    if (status === "authenticated") {
      if (session.error === "RefreshAccessTokenError") {
      
        signOut();
        dispatch(logout());
        return;
      }
      
      
      if (!isAuthenticated) {
        dispatch(
          setCredentials({
            user: session.user,
            token: session.accessToken,
          })
        );
      }
    }

    if (status === "unauthenticated") {
      
      if (isAuthenticated) {
        dispatch(logout());
      }
    }
  }, [session, status, dispatch, isAuthenticated]);

  return <>{children}</>;
}