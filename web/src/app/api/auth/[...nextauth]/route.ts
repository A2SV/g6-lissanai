// app/api/auth/[...nextauth]/route.ts
/* eslint-disable @typescript-eslint/no-explicit-any */
import NextAuth, { AuthOptions } from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import CredentialsProvider from "next-auth/providers/credentials";
import { IAuthResponse, IUser } from "@/types";

// Function to refresh the access token
async function refreshAccessToken(token: any) {
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/refresh`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ refresh_token: token.refreshToken }),
    });

    const refreshedTokens = await response.json();

    if (!response.ok) {
      throw refreshedTokens;
    }

    // Return the updated token information
    return {
      ...token,
      accessToken: refreshedTokens.access_token,
      // Calculate new expiration time
      expiresAt: Date.now() + refreshedTokens.expires_in * 1000,
      // Keep the original refresh token if the API doesn't send a new one
      refreshToken: refreshedTokens.refresh_token ?? token.refreshToken,
    };
  } catch (error) {
    console.error("Error refreshing access token:", error);
    // Sign the user out by returning an error
    return {
      ...token,
      error: "RefreshAccessTokenError",
    };
  }
}

export const authOptions: AuthOptions = {
  
  session: {
    strategy: "jwt",
  },
  
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      
      async authorize(credentials, req) {
        if (!credentials?.email || !credentials?.password) {
          throw new Error("Missing credentials");
        }

        const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/login`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: credentials.email,
            password: credentials.password,
          }),
        });

        if (!res.ok) {
          
          const errorData = await res.json();
          throw new Error(errorData.error || "Invalid credentials");
        }

        const data: IAuthResponse = await res.json();

        
        return data as any;
      },
    }),
  ],
  
  callbacks: {
    
    async jwt({ token, user, account }) {
    
      if (account && user) {
    
        if (account.provider === "google") {
    
          const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/social`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              provider: 'google',
              access_token: account.access_token, 
              name: user.name,
              email: user.email,
            })
          });

          if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.error || "Social login failed");
          }

          const socialLoginData: IAuthResponse = await res.json();
          
          token.accessToken = socialLoginData.access_token;
          token.refreshToken = socialLoginData.refresh_token;
          token.expiresAt = Date.now() + socialLoginData.expires_in * 1000;
          token.user = socialLoginData.user;
          
        } else {
          
          const backendResponse = user as unknown as IAuthResponse;
          token.accessToken = backendResponse.access_token;
          token.refreshToken = backendResponse.refresh_token;
          token.expiresAt = Date.now() + backendResponse.expires_in * 1000;
          token.user = backendResponse.user;
        }

        return token;
      }

      
      if (Date.now() < (token.expiresAt as number)) {
        return token; 
      }

      console.log("Access token expired, attempting to refresh...");
      return refreshAccessToken(token);
    },


    async session({ session, token }) {
      session.user = token.user as IUser;
      session.accessToken = token.accessToken as string;
      session.error = token.error as "RefreshAccessTokenError" | undefined;
      return session;
    },
  },
  
  pages: {
    signIn: "/login",
  },
};

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };