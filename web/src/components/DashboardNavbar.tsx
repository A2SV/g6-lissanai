"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useSession, signOut } from "next-auth/react";
import { FiMenu, FiX } from "react-icons/fi";

interface NavigationItem {
  label: string;
  href: string;
}

export default function DashboardNavbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const { data: session, status } = useSession();
  const isAuthenticated = status === "authenticated";

  useEffect(() => {
    if (isMenuOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "auto";
    }
  }, [isMenuOpen]);

  const navigationItems: NavigationItem[] = [
    { label: "Features", href: "#features" },
    { label: "How It Works", href: "#how-it-works" },
    { label: "Success Stories", href: "#testimonials" },
  ];

  return (
    <>
      <nav className="bg-white/80 backdrop-blur-md h-16 sticky top-0 z-50 w-full border-b border-gray-100">
        {" "}
        {/* Changed h-[73px] to h-16 for better fit */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full">
          <div className="flex items-center justify-between h-full">
            <Link href="/" className="flex items-center gap-2">
              {" "}
              {/* Updated logo to use image */}
              <img
                src="/images/logo0.png"
                alt="LissanAI"
                className="h-12 w-12"
              />
              <div className="text-[#1c75bd] font-bold text-lg">ልssanAI</div>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
              {navigationItems.map((item) => (
                <a
                  key={item.label}
                  href={item.href}
                  className="text-[#476385] hover:text-[#112d4e] transition-colors text-base font-medium"
                >
                  {item.label}
                </a>
              ))}
              <div className="flex items-center space-x-4">
                {status === "loading" ? (
                  <div className="h-9 w-48 bg-gray-200 rounded-lg animate-pulse"></div>
                ) : isAuthenticated ? (
                  <>
                    <Link href="/dashboard">
                      <button className="bg-[#337fa1] text-white rounded-lg px-5 py-2 text-sm font-semibold hover:bg-[#225d79] transition-colors">
                        Dashboard
                      </button>
                    </Link>
                    <button
                      onClick={() => signOut()}
                      className="bg-[#f0f2f5] rounded-lg px-5 py-2 text-sm font-semibold text-black hover:bg-gray-200 transition-colors"
                    >
                      Log Out
                    </button>
                  </>
                ) : (
                  <>
                    <Link href="/login">
                      <button className="bg-[#f0f2f5] border border-transparent rounded-lg px-5 py-2 text-sm font-semibold text-black hover:bg-gray-200 transition-colors">
                        Log In
                      </button>
                    </Link>
                    <Link href="/signup">
                      <button className="bg-[#0057b7] text-white rounded-lg px-5 py-2 text-sm font-semibold hover:bg-[#004499] transition-colors">
                        Sign Up
                      </button>
                    </Link>
                  </>
                )}
              </div>
            </div>

            {/* Mobile Menu Button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsMenuOpen(true)}
                aria-label="Open menu"
              >
                <FiMenu size={28} className="text-gray-700" />
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Mobile Menu Overlay */}
      {isMenuOpen && (
        <div className="fixed inset-0 bg-gray-900/90 z-50 flex flex-col items-center justify-center md:hidden">
          <button
            onClick={() => setIsMenuOpen(false)}
            className="absolute top-6 right-6"
            aria-label="Close menu"
          >
            <FiX size={32} className="text-white" />
          </button>
          <nav className="flex flex-col items-center gap-8">
            {navigationItems.map((item) => (
              <a
                key={item.label}
                href={item.href}
                onClick={() => setIsMenuOpen(false)}
                className="text-white text-2xl font-semibold"
              >
                {item.label}
              </a>
            ))}
            <div className="flex flex-col items-center gap-6 mt-8">
              {status === "loading" ? (
                <div className="h-12 w-32 bg-gray-600 rounded-lg animate-pulse"></div>
              ) : isAuthenticated ? (
                <>
                  <Link href="/dashboard" onClick={() => setIsMenuOpen(false)}>
                    <button className="bg-white text-black rounded-lg px-8 py-3 text-lg font-semibold hover:bg-gray-200 transition-colors">
                      Dashboard
                    </button>
                  </Link>
                  <button
                    onClick={() => {
                      signOut();
                      setIsMenuOpen(false);
                    }}
                    className="text-white text-lg font-semibold"
                  >
                    Log Out
                  </button>
                </>
              ) : (
                <>
                  <Link href="/login" onClick={() => setIsMenuOpen(false)}>
                    <button className="bg-white border border-transparent rounded-lg px-8 py-3 text-lg font-semibold text-black hover:bg-gray-200 transition-colors">
                      Log In
                    </button>
                  </Link>
                  <Link href="/signup" onClick={() => setIsMenuOpen(false)}>
                    <button className="bg-[#0057b7] text-white rounded-lg px-8 py-3 text-lg font-semibold hover:bg-[#004499] transition-colors">
                      Sign Up
                    </button>
                  </Link>
                </>
              )}
            </div>
          </nav>
        </div>
      )}
    </>
  );
}
