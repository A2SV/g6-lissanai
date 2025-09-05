import React from "react";
import Header from "@/components/Header";
import Link from "next/link";

const progressData = [
  { label: "Speaking Confidence", value: 53 },
  { label: "Pronunciation", value: 60 },
  { label: "Email Writing", value: 75 },
  { label: "Grammar Accuracy", value: 60 },
];

type ProgressBarProps = {
  value: number;
};

const ProgressBar = ({ value }: ProgressBarProps) => (
  <>
    {/* Horizontal bar for mobile */}
    <div className="block sm:hidden w-full max-w-[220px] h-3 bg-gray-200 rounded-full relative">
      <div
        className="h-3 rounded-full bg-green-500"
        style={{ width: `${value}%` }}
      ></div>
      <span className="absolute right-0 top-1/2 -translate-y-1/2 text-sm font-bold text-gray-700 pr-3">
        {value}%
      </span>
    </div>
    {/* Circle for desktop */}
    <div className="hidden sm:flex w-16 h-16 relative items-center justify-center">
      <svg className="absolute top-0 left-0" width="64" height="64">
        <circle
          cx="32"
          cy="32"
          r="28"
          stroke="#e5e7eb"
          strokeWidth="8"
          fill="none"
        />
        <circle
          cx="32"
          cy="32"
          r="28"
          stroke="#22c55e"
          strokeWidth="8"
          fill="none"
          strokeDasharray={2 * Math.PI * 30}
          strokeDashoffset={2 * Math.PI * 28 * (1 - value / 100)}
          strokeLinecap="round"
          transform="rotate(-90 32 32)"
        />
      </svg>
      <span className="font-bold text-lg">{value}%</span>
    </div>
  </>
);

export default function Dashboard() {
  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <Header />

      {/* Welcome Card */}
      <section className="max-w-5xl mx-auto mt-8 px-4">
        <div className="bg-gradient-to-r from-[#0655a5] to-[#337EA2] rounded-xl p-6 sm:p-8 flex flex-col sm:flex-row items-center justify-between relative overflow-hidden">
          <div className="w-full sm:w-2/3 mb-6 sm:mb-0">
            <h2 className="text-white text-xl sm:text-2xl font-bold mb-2">
              Welcome back to LissanAI!
            </h2>
            <p className="text-white mb-4 text-base sm:text-lg">
              Continue your English learning journey with your AI coach
            </p>
            <Link href="/learn">
              <button className="w-full bg-white text-gray-700 font-semibold px-5 py-2 rounded-full flex items-center gap-1 shadow hover:bg-gray-100 text-base sm:text-lg">
                <span>▶ </span>
                Continue Learning
                <span className="bg-orange-100 text-orange-600 px-2 py-1 rounded-full text-xs ml-2">
                  1 day streak 🔥
                </span>
              </button>
            </Link>
          </div>
          <div className="flex flex-col items-center w-full sm:w-auto">
           <div className="relative h-64 w-64 md:h-80 md:w-80 mx-auto flex items-center justify-center">
                <img
                    src="/videos/dashboard.gif" // Path to your GIF file
                    alt="LissanAI Mascot Animation" // Accessible alt text for the image
                    className="absolute inset-0 w-full h-full object-contain" // Keep consistent styling
                />
            </div>
          </div>
        </div>
      </section>

      {/* Progress Section */}
      <section className="max-w-5xl mx-auto mt-8 px-4">
        <div className="bg-white border rounded-xl p-4 sm:p-6 shadow-sm">
          <h3 className="font-semibold text-base sm:text-lg mb-2 flex items-center gap-2 text-gray-700">
            <span className="text-gray-700">➤</span> Your Progress
          </h3>
          <p className="text-gray-500 text-sm mb-4">
            Track your English learning milestones
          </p>
          <div className="flex flex-wrap gap-6 sm:gap-9 justify-center">
            {progressData.map((item) => (
              <div
                key={item.label}
                className="flex flex-col items-center text-gray-600 w-1/2 sm:w-auto mb-4 sm:mb-0"
              >
                <ProgressBar value={item.value} />
                <span className="mt-2 text-sm text-black font-medium text-center">
                  {item.label}
                </span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Continue Learning Cards */}
      <section className="max-w-5xl mx-auto mt-8 mb-12 px-4">
        <h3 className="font-bold text-lg sm:text-xl mb-4 text-gray-700">
          Continue Learning
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {/* Mock Interview */}
          <div className="bg-white border rounded-xl p-4 sm:p-6 shadow-sm flex flex-col justify-between">
            <div>
              <h4 className="font-semibold text-base sm:text-lg mb-1 text-gray-700">
                Mock Interview
              </h4>
              <p className="text-sm mb-4 text-gray-700">
                Practice with AI feedback
              </p>
            </div>
            <Link href="/interview">
              <button className="w-full bg-gradient-to-r from-[#337fa1] to-[#0655a5] text-white font-semibold px-5 py-2 rounded-full gap-2 shadow hover:opacity-90 text-base">
                Start Practice →
              </button>
            </Link>
          </div>
          {/* Grammar Coach */}
          <div className="bg-white border rounded-xl p-4 sm:p-6 shadow-sm flex flex-col justify-between">
            <div>
              <h4 className="font-semibold text-base sm:text-lg mb-1 text-gray-700">
                Grammar Coach
              </h4>
              <p className="text-gray-700 text-sm mb-4">Improve your writing</p>
            </div>
            <Link href="/grammar">
              <button className="w-full bg-gray-100 text-gray-700 font-semibold px-5 py-2 rounded-full gap-2 shadow hover:bg-gray-200 text-base">
                Check Grammar →
              </button>
            </Link>
          </div>
          {/* Email Drafting */}
          <div className="bg-white border rounded-xl p-4 sm:p-6 shadow-sm flex flex-col justify-between">
            <div>
              <h4 className="font-semibold text-base sm:text-lg mb-1 text-gray-700">
                Email Drafting
              </h4>
              <p className="text-gray-700 text-sm mb-4">
                Write professional emails
              </p>
            </div>
            <Link href="/email/drafting">
              <button className="w-full bg-gray-100 text-gray-700 font-semibold px-5 py-2 rounded-full gap-2 shadow hover:bg-gray-200 text-base">
                Draft Email →
              </button>
            </Link>
          </div>
          {/* Pronunciation */}
          <div className="bg-white border rounded-xl p-4 sm:p-6 shadow-sm flex flex-col justify-between">
            <div>
              <h4 className="font-semibold text-base sm:text-lg mb-1 text-gray-700">
                Pronunciation
              </h4>
              <p className="text-gray-700 text-sm mb-4">
                Perfect your speaking
              </p>
            </div>
            <Link href="/pronunciation">
              <button className="w-full bg-gray-100 text-gray-700 font-semibold px-5 py-2 rounded-full gap-2 shadow hover:bg-gray-200 text-base">
                Practice Speaking →
              </button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
