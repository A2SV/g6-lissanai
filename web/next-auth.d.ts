
import { DefaultSession, DefaultUser } from "next-auth";
import { JWT, DefaultJWT } from "next-auth/jwt";
import { IUser } from "./types"; 

/**
 * Module augmentation for `next-auth` types. Allows us to add custom properties to the `session`
 * object and keep type safety.
 *
 * @see https://next-auth.js.org/getting-started/typescript#module-augmentation
 */

declare module "next-auth" {
  /**
   * The `session` object returned by `useSession`, `getSession`
   * 
   */
  interface Session {
    user: IUser; 
    accessToken: string;
    error?: "RefreshAccessTokenError"; 
  }
}

declare module "next-auth/jwt" {
  /**
   * The `token` object passed to the `jwt` callback.
   * 
   */
  interface JWT extends DefaultJWT {
    user: IUser;
    accessToken: string;
    refreshToken: string;
    expiresAt: number; 
  }
}