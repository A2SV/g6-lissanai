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
    <>
      <header className="bg-white shadow-sm border-b border-gray-200 fixed top-0 z-50 w-full h-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link href="/" className="flex items-center gap-2">
              <img
                src="/images/logo0.png"
                alt="LissanAI"
                className="h-12 w-12"
              />
              <div className="text-[#1c75bd] font-bold text-lg">ልssanAI</div>
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

            {/* Desktop Profile Image with Dropdown */}
            <div className="relative hidden md:flex items-center self-center">
              <button
                onClick={() => setIsProfileDropdownOpen(!isProfileDropdownOpen)}
                className="flex flex-col items-center space-y-1 text-gray-700 hover:text-blue-600"
              >
                <img
                  src={displayAvatar}
                  alt="Profile"
                  className="w-12 h-12 rounded-full object-cover bg-center border-2 border-white shadow-md"
                />
              </button>
              {isProfileDropdownOpen && (
                <div className="absolute right-0 top-full mt-2 w-48 bg-white border border-gray-200 rounded-md shadow-lg z-50">
                  <div className="px-4 py-2 border-b border-gray-200">
                    <p className="text-sm font-medium text-gray-900">
                      {(typeof userData?.name === "string" && userData?.name) ||
                        "User"}
                    </p>
                    <p className="text-xs text-gray-500">
                      {(typeof userData?.email === "string" &&
                        userData.email) ||
                        ""}
                    </p>
                  </div>
                  <Link
                    href="/profile"
                    className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    onClick={() => setIsProfileDropdownOpen(false)}
                  >
                    View Profile
                  </Link>
                  <button
                    onClick={() => {
                      handleLogout();
                      setIsProfileDropdownOpen(false);
                    }}
                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 flex items-center gap-2"
                  >
                    <LogOut className="h-4 w-4" /> Logout
                  </button>
                </div>
              )}
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
        </div>
      </header>

      {/* Mobile Navigation Overlay */}
      {isMenuOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
          onClick={() => setIsMenuOpen(false)}
        >
          <div className="fixed top-16 left-0 right-0 bg-white shadow-lg z-50 max-h-screen overflow-y-auto">
            <nav className="flex flex-col space-y-4 p-4">
              {navigationItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`text-lg font-medium ${
                    pathname === item.href
                      ? "text-blue-600"
                      : "text-gray-700 hover:text-blue-600"
                  }`}
                  onClick={() => setIsMenuOpen(false)}
                >
                  {item.label}
                </Link>
              ))}
              {/* Mobile Profile Section */}
              <div className="border-t border-gray-200 pt-4 text-center">
                <img
                  src={displayAvatar}
                  alt="Profile"
                  className="w-12 h-12 rounded-full object-cover mx-auto mb-3"
                />
                <div>
                  <p className="text-sm font-medium text-gray-900">
                    {(typeof userData?.name === "string" && userData?.name) ||
                      "User"}
                  </p>
                  <p className="text-xs text-gray-500">
                    {(typeof userData?.email === "string" && userData.email) ||
                      ""}
                  </p>
                </div>
                <Link
                  href="/profile"
                  className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-md mt-3"
                  onClick={() => setIsMenuOpen(false)}
                >
                  View Profile
                </Link>
                <button
                  onClick={() => {
                    handleLogout();
                    setIsMenuOpen(false);
                  }}
                  className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 rounded-md flex items-center gap-2 mt-2"
                >
                  <LogOut className="h-4 w-4" /> Logout
                </button>
              </div>
            </nav>
          </div>
        </div>
      )}
    </>
  );
}
