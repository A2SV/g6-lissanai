"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import toast, { Toaster } from "react-hot-toast";


import { FcGoogle } from "react-icons/fc";
import {
  FiUser,
  FiMail,
  FiLock,
  FiEye,
  FiEyeOff,
  FiArrowRight,
} from "react-icons/fi";
import { SignUpSchema, TSignUpSchema } from "@/app/lib/zod";

export default function SignUpPage() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<TSignUpSchema>({
    resolver: zodResolver(SignUpSchema),
  });

  
  const handleGoogleSignUp = async () => {
    
    signIn("google", { callbackUrl: "/" });
  };

  
  const onSubmit = async (data: TSignUpSchema) => {
    setIsSubmitting(true);
    try {
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          fullName: data.fullName,
          email: data.email,
          password: data.password,
          confirmPassword: data.confirmPassword,
          agreedToTerms: data.agreedToTerms,
        })
      });

      const result = await response.json();

      if (!response.ok) {
        toast.error(result.message || "Registration failed.");
      } else {
        toast.success("Registration successful! Redirecting to sign in...");
        reset();
        router.push("/login");
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
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-extrabold text-gray-800">
            Join the Adventure !
          </h1>
          <p className="text-gray-500 mt-2 text-lg">
            start your English mastery journey today 🚀
          </p>
        </div>

        <div className="w-full max-w-lg bg-white rounded-2xl border border-green-200 shadow-xl p-8 space-y-6">
          <div className="text-center">
            <h2 className="text-2xl font-bold text-green-600">Create Account</h2>
            <p className="text-gray-400 mt-1">
              join 100+ learners already winning
            </p>
          </div>

          
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          
            <div>
              <label className="text-sm font-medium text-gray-700">
                Full Name
              </label>
              <div className="relative mt-1">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <FiUser className="w-5 h-5 text-gray-400" />
                </div>
                <input
                  type="text"
                  {...register("fullName")} 
                  placeholder="Your Full Name"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                />
              </div>
              {errors.fullName && <p className="mt-1 text-sm text-red-600">{errors.fullName.message}</p>}
            </div>

            
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
                  type={showPassword ? "text" : "password"}
                  {...register("password")} 
                  placeholder="Create a strong password"
                  className="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <FiEyeOff /> : <FiEye />}
                </button>
              </div>
              {errors.password && <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>}
            </div>

            
            <div>
              <label className="text-sm font-medium text-gray-700">
                Confirm Password ✅
              </label>
              <div className="relative mt-1">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <FiLock className="w-5 h-5 text-gray-400" />
                </div>
                <input
                  type={showConfirmPassword ? "text" : "password"}
                  {...register("confirmPassword")} 
                  placeholder="Confirm your password"
                  className="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
                >
                  {showConfirmPassword ? <FiEyeOff /> : <FiEye />}
                </button>
              </div>
              {errors.confirmPassword && <p className="mt-1 text-sm text-red-600">{errors.confirmPassword.message}</p>}
            </div>

            
            <div className="flex items-start">
              <div className="flex items-center h-5">
                <input
                  id="terms"
                  type="checkbox"
                  {...register("agreedToTerms")} 
                  className="h-4 w-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
              </div>
              <div className="ml-3 text-sm">
                <label htmlFor="terms" className="text-gray-600">
                  I agree to the{" "}
                  <Link href="/terms" className="font-medium text-green-600 hover:underline">
                    Terms of Service
                  </Link>{" "}
                  and{" "}
                  <Link href="/privacy" className="font-medium text-green-600 hover:underline">
                    Privacy Policy
                  </Link>
                </label>
                {errors.agreedToTerms && <p className="mt-1 text-sm text-red-600">{errors.agreedToTerms.message}</p>}
              </div>
            </div>


            <button
              type="submit"
              disabled={isSubmitting} 
              className="w-full flex items-center justify-center gap-2 py-3 px-4 text-white font-semibold rounded-lg bg-gradient-to-r from-green-400 to-blue-500 hover:opacity-90 shadow-md transition-opacity disabled:opacity-50"
            >
              {isSubmitting ? "Creating Account..." : "Create Account"}
              {!isSubmitting && <FiArrowRight className="w-5 h-5" />}
            </button>
          </form>

          <div className="flex items-center">
            <div className="flex-grow border-t border-gray-200"></div>
            <span className="flex-shrink mx-4 text-sm text-gray-400">or</span>
            <div className="flex-grow border-t border-gray-200"></div>
          </div>

          
          <button
            onClick={handleGoogleSignUp}
            className="w-full flex items-center justify-center gap-3 py-3 px-4 border border-green-300 rounded-lg hover:bg-green-50 transition-colors"
          >
            <FcGoogle size={24} />
            <span className="font-medium text-gray-700">
              Continue with Google
            </span>
          </button>

          
          <p className="text-sm text-center text-gray-500">
            Already have an account?{" "}
            <Link
              href="/login" 
              className="font-semibold text-green-600 hover:underline"
            >
              signin 👋
            </Link>
          </p>
        </div>
      </div>
    </>
  );
}