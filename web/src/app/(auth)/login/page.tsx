

"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import toast, { Toaster } from "react-hot-toast";
import Link from "next/link";


import { FcGoogle } from "react-icons/fc";
import { FiMail, FiLock, FiArrowRight } from "react-icons/fi";
import { SignInSchema, TSignInSchema } from "@/app/lib/zod";

export default function SignInPage() {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);

  
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<TSignInSchema>({
    resolver: zodResolver(SignInSchema),
  });

  
  const handleGoogleSignIn = async () => {
    signIn("google", { callbackUrl: "/" });
  };

  
  const onSubmit = async (data: TSignInSchema) => {
    setIsSubmitting(true);
    try {
      const result = await signIn("credentials", {
        redirect: false,
        email: data.email,
        password: data.password,
      });

      if (result?.error) {

        toast.error(result.error);
      } else if (result?.ok) {

        toast.success("Signed in successfully!");
        router.push("/");
      }
    } catch (error) {
      toast.error("An unexpected error occurred. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <Toaster position="top-center" />
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="w-full max-w-md bg-white rounded-2xl border border-green-200 shadow-xl p-8 space-y-6">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-green-600">Sign In</h1>
            <p className="text-gray-500 mt-2">
              Continue your path to English mastery! 🚀
            </p>
          </div>

          
          <button
            onClick={handleGoogleSignIn}
            className="w-full flex items-center justify-center gap-3 py-3 px-4 border border-green-300 rounded-lg hover:bg-green-50 transition-colors"
          >
            <FcGoogle size={24} />
            <span className="font-medium text-gray-700">Sign In with Google</span>
          </button>

          <div className="flex items-center">
            <div className="flex-grow border-t border-gray-200"></div>
            <span className="flex-shrink mx-4 text-sm text-gray-400">
              Or continue with email
            </span>
            <div className="flex-grow border-t border-gray-200"></div>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            
            <div>
              <label className="text-sm font-medium text-gray-700">
                Email Address 📧
              </label>
              <div className="relative mt-1">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <FiMail className="w-5 h-5 text-gray-400" />
                </div>
                <input
                  type="email"
                  {...register("email")}
                  placeholder="your.email@example.com"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                />
              </div>
              {errors.email && <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>}
            </div>

            
            <div>
              <label className="text-sm font-medium text-gray-700">
                Password 🔐
              </label>
              <div className="relative mt-1">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <FiLock className="w-5 h-5 text-gray-400" />
                </div>
                <input
                  type="password"
                  {...register("password")}
                  placeholder="Enter your password"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                />
              </div>
              {errors.password && <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>}
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  className="h-4 w-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span className="ml-2 text-sm text-gray-600">Remember me</span>
              </label>
              <Link
                href="/forgot-password"
                className="text-sm font-medium text-green-600 hover:underline"
              >
                Forgot password?
              </Link>
            </div>

            
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full flex items-center justify-center gap-2 py-3 px-4 text-white font-semibold rounded-lg bg-gradient-to-r from-green-400 to-blue-500 hover:opacity-90 shadow-md disabled:opacity-50"
            >
              {isSubmitting ? "Signing In..." : "Sign In"}
              {!isSubmitting && <FiArrowRight className="w-5 h-5" />}
            </button>
          </form>

          <p className="text-sm text-center text-gray-500">
            New to LissanAI?{" "}
            <Link
              href="/signup"
              className="font-semibold text-green-600 hover:underline"
            >
              Create account
            </Link>
          </p>

          
          <div className="border-t border-gray-200 pt-6 flex items-center justify-around text-sm text-gray-600">
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 bg-green-400 rounded-full"></span>
              <span>Secure Login</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 bg-blue-500 rounded-full"></span>
              <span>Fast Access</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 bg-pink-400 rounded-full"></span>
              <span>Always Available</span>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
