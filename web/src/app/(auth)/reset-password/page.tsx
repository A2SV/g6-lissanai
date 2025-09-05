
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";

import { useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import toast, { Toaster } from "react-hot-toast";
import Link from "next/link";
import { FiLock, FiArrowLeft } from "react-icons/fi";
import { ResetPasswordSchema, TResetPasswordSchema } from "@/app/lib/zod";


function ResetPasswordForm() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const token = searchParams.get("token");

    const [isSubmitting, setIsSubmitting] = useState(false);

    const {
        register,
        handleSubmit,
        formState: { errors },
    } = useForm<TResetPasswordSchema>({
        resolver: zodResolver(ResetPasswordSchema),
    });

    const onSubmit = async (data: TResetPasswordSchema) => {
        if (!token) {
            toast.error("No reset token found. Please request a new link.");
            return;
        }

        setIsSubmitting(true);
        try {
            const response = await fetch('/api/auth/reset-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    new_password: data.new_password,
                    confirmPassword: data.confirmPassword,
                    token: token,
                })
            });

            const result = await response.json();
            if (!response.ok) {
                toast.error(result.message);
            } else {
                toast.success(result.message);
                router.push('/login');
            }
        } catch (error) {
            toast.error("An unexpected error occurred.");
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="w-full max-w-md bg-white rounded-2xl border border-green-200 shadow-xl p-8 space-y-6">
            <div className="text-center">
                <h1 className="text-2xl font-bold text-green-600">Set New Password</h1>
                <p className="text-gray-500 mt-2">
                    Create a new, strong password.
                </p>
            </div>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                <div>
                    <label className="text-sm font-medium text-gray-700">New Password 🔐</label>
                    <div className="relative mt-1">
                        <FiLock className="absolute inset-y-0 left-3 top-3.5 h-5 w-5 text-gray-400" />
                        <input type="password" {...register("new_password")} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg" />
                    </div>
                    {errors.new_password && <p className="mt-1 text-sm text-red-600">{errors.new_password.message}</p>}
                </div>
                <div>
                    <label className="text-sm font-medium text-gray-700">Confirm New Password ✅</label>
                    <div className="relative mt-1">
                        <FiLock className="absolute inset-y-0 left-3 top-3.5 h-5 w-5 text-gray-400" />
                        <input type="password" {...register("confirmPassword")} className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg" />
                    </div>
                    {errors.confirmPassword && <p className="mt-1 text-sm text-red-600">{errors.confirmPassword.message}</p>}
                </div>
                <button type="submit" disabled={isSubmitting} className="w-full py-3 px-4 text-white font-semibold rounded-lg bg-gradient-to-r from-green-400 to-blue-500 hover:opacity-90 shadow-md disabled:opacity-50">
                    {isSubmitting ? "Resetting..." : "Reset Password"}
                </button>
            </form>
             <div className="text-center">
                <Link href="/login" className="inline-flex items-center gap-2 text-sm font-medium text-green-600 hover:underline">
                    <FiArrowLeft />
                    Back to Sign In
                </Link>
            </div>
        </div>
    );
}


export default function ResetPasswordPage() {
    return (
        <>
            <Toaster position="top-center" />
            <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
                <Suspense fallback={<div>Loading...</div>}>
                    <ResetPasswordForm />
                </Suspense>
            </div>
        </>
    )
}