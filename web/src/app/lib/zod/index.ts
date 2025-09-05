// app/lib/zod/index.ts

import { z } from 'zod';

export const SignInSchema = z.object({
  email: z.string().email({ message: 'Please enter a valid email address' }),
  password: z
    .string()
    .min(1, { message: 'Password is required' }), 
});



export const SignUpSchema = z.object({
  fullName: z
    .string()
    .min(2, { message: 'Full name must be at least 2 characters long' })
    .max(50, { message: 'Full name must be less than 50 characters' }),
  email: z.string().email({ message: 'Please enter a valid email address' }),
  password: z
    .string()
    .min(6, { message: 'Password must be at least 6 characters long' }),
  confirmPassword: z
    .string()
    .min(6, { message: 'Password must be at least 6 characters long' }),
  agreedToTerms: z
    .boolean()
    .refine((val) => val === true, {
      message: 'You must accept the Terms and Conditions',
    }),
}).refine((data) => data.password === data.confirmPassword, {

  message: "Passwords do not match",
  path: ["confirmPassword"], 
});

export const ForgotPasswordSchema = z.object({
  email: z.string().email({ message: 'Please enter a valid email address' }),
});
export const ResetPasswordSchema = z.object({
  new_password: z
    .string()
    .min(6, { message: 'Password must be at least 6 characters long' }),
  confirmPassword: z
    .string()
    .min(6, { message: 'Password must be at least 6 characters long' }),
}).refine((data) => data.new_password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});



export type TSignInSchema = z.infer<typeof SignInSchema>;
export type TSignUpSchema = z.infer<typeof SignUpSchema>;
export type TForgotPasswordSchema = z.infer<typeof ForgotPasswordSchema>;
export type TResetPasswordSchema = z.infer<typeof ResetPasswordSchema>;