"use client";
import Link from "next/link";
import { FiMenu, FiX } from "react-icons/fi";
import { useState, useEffect } from "react";
import { usePathname } from "next/navigation";
import { useSession, signOut } from "next-auth/react";
import { ChevronDown, LogOut } from "lucide-react";

const navigationItems = [
  { label: "Mock Interviews", href: "/interview" },
  { label: "Grammar Coach", href: "/grammar" },
  { label: "Learn", href: "/learn" },
  { label: "Email Drafting", href: "/email/drafting" },
  { label: "Pronunciation", href: "/pronunciation" },
];

interface HeaderProps {
  avatarImage?: string;
}

export default function Header({ avatarImage }: HeaderProps) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isProfileDropdownOpen, setIsProfileDropdownOpen] = useState(false);
  const [storedAvatar, setStoredAvatar] = useState<string | null>(null);
  type UserData = Record<string, unknown> | null;
  const [userData, setUserData] = useState<UserData>(null);
  const pathname = usePathname();
  const { data: session } = useSession();

  useEffect(() => {
    document.body.style.overflow = isMenuOpen ? "hidden" : "auto";
  }, [isMenuOpen]);

  useEffect(() => {
    const savedAvatar = localStorage.getItem("avatarImage");
    if (savedAvatar) setStoredAvatar(savedAvatar);
  }, []);

  useEffect(() => {
    const fetchUser = async () => {
      if (!session?.accessToken) return;
      try {
        const response = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`,
          {
            headers: {
              Authorization: `Bearer ${session.accessToken}`,
            },
          }
        );
        if (response.ok) {
          const data = await response.json();
          setUserData(data);
        }
      } catch (err) {
        console.error("Error fetching user:", err);
      }
    };
    fetchUser();
  }, [session]);

  const defaultAvatar =
    "https://via.placeholder.com/24x24/cccccc/000000?text=U";
  const displayAvatar = avatarImage || storedAvatar || defaultAvatar;

  const handleLogout = () => {
    signOut({ callbackUrl: "/" });
  };

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 fixed top-0 z-50 w-full h-14">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-18">
          <Link href="/" className="flex items-center gap-2">
            <img src="/images/logo0.png" alt="LissanAI" className="h-15 w-14" />
            <div className="text-[#1c75bd] font-bold">ልssanAI</div>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex space-x-8">
            {navigationItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`text-sm font-medium ${
                  pathname === item.href
                    ? "text-blue-600"
                    : "text-gray-700 hover:text-blue-600"
                }`}
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* Desktop Profile Image */}
          <div className="hidden md:flex items-center">
            <Link
              href="/profile"
              className={`p-2 rounded-full hover:bg-gray-100 transition-colors ${
                pathname === "/profile" ? "bg-gray-100" : ""
              }`}
              aria-label="Profile"
            >
              <img
                src={displayAvatar}
                alt="User Avatar"
                className="w-6 h-6 rounded-full object-cover"
              />
            </Link>
          </div>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setIsMenuOpen(!isMenuOpen)}
          className="md:hidden p-2 rounded-md text-gray-700 hover:text-blue-600"
        >
          {isMenuOpen ? (
            <FiX className="h-6 w-6" />
          ) : (
            <FiMenu className="h-6 w-6" />
          )}
        </button>
      </div>

      {/* Mobile Navigation */}
      {isMenuOpen && (
        <div className="md:hidden border-t border-gray-200 py-4">
          <nav className="flex flex-col space-y-2">
            {navigationItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`text-sm font-medium ${
                  pathname === item.href
                    ? "text-blue-600"
                    : "text-gray-700 hover:text-blue-600"
                }`}
                onClick={() => setIsMenuOpen(false)}
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>
      )}
    </header>
  );
}
