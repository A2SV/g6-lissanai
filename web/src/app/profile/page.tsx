"use client";

import { useState, useRef, useEffect } from "react";
import { useSession, signOut } from "next-auth/react";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";
import {
  Camera,
  Edit3,
  Share2,
  MoreHorizontal,
  MessageSquare,
  Award,
  Star,
  Clock,
  MapPin,
  Calendar,
  Shield,
  Mail,
  Phone,
  Globe,
  BookOpen,
  Mic,
  Activity,
  LogOut,
  Flame,
  Loader,
  Bell,
  CheckCircle,
  XCircle,
} from "lucide-react";
import { motion } from "framer-motion";
import CalendarHeatmap from "react-calendar-heatmap";
import "react-calendar-heatmap/dist/styles.css";

export interface HeaderProps {
  avatarImage?: string;
  name?: string;
}

const motivationalMessages = [
  "Keep it up, you're learning fast!",
  "Every step counts towards mastery!",
  "You're doing amazing—stay focused!",
  "Progress is happening, one word at a time!",
  "Believe in yourself, you're unstoppable!",
];

const getRandomMessage = () => {
  return motivationalMessages[
    Math.floor(Math.random() * motivationalMessages.length)
  ];
};

export default function Profile() {
  const { data: session, update } = useSession();
  const [activeTab, setActiveTab] = useState<
    "overview" | "activity" | "awards"
  >("overview");
  const [avatarImage, setAvatarImage] = useState<string | null>(null);
  const [backgroundImage, setBackgroundImage] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [user, setUser] = useState({
    name: "",
    email: "",
    bio: "",
    provider: "",
    created_at: "",
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const avatarInputRef = useRef<HTMLInputElement>(null);
  const backgroundInputRef = useRef<HTMLInputElement>(null);

  const [quote, setQuote] = useState("Keep it up, you're learning fast!");
  const [streakInfo, setStreakInfo] = useState({
    current_streak: 0,
    longest_streak: 0,
    can_freeze: true,
    freeze_count: 0,
    max_freezes: 2,
    streak_frozen: false,
  });
  const [calendarData, setCalendarData] = useState<
    { date: string; count: number }[]
  >([]);
  const [totalSessions, setTotalSessions] = useState(0);

  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  const [isNotificationsEnabled, setIsNotificationsEnabled] = useState(false);
  const [showNotificationPopup, setShowNotificationPopup] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState("");

  const [notificationCount, setNotificationCount] = useState(0); // Remains 0 since no API

  const [popupType, setPopupType] = useState<"success" | "error">("success");

  useEffect(() => {
    const interval = setInterval(() => {
      setQuote(getRandomMessage());
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const fetchData = async () => {
      if (!session?.accessToken) {
        setError("No session available. Please log in.");
        setLoading(false);
        return;
      }
      try {
        const userResponse = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`,
          {
            headers: {
              Authorization: `Bearer ${session?.accessToken ?? ""}`,
            },
          }
        );
        if (!userResponse.ok) {
          let errorData;
          try {
            errorData = await userResponse.json();
          } catch {
            errorData = { message: "Invalid response from server" };
          }
          throw new Error(errorData.message || "Failed to fetch user data");
        }
        let userData;
        try {
          userData = await userResponse.json();
        } catch {
          throw new Error("Invalid JSON response for user data");
        }
        setUser({
          name: userData.name || session.user?.name || "User",
          email: userData.email || session.user?.email || "",
          bio: userData.settings?.bio || "",
          provider: userData.provider || session.user?.provider || "N/A",
          created_at: userData.created_at || new Date().toISOString(),
        });
        setStreakInfo({
          current_streak: userData.current_streak || 0,
          longest_streak: userData.longest_streak || 0,
          can_freeze: (userData.freeze_count || 0) < 2,
          freeze_count: userData.freeze_count || 0,
          max_freezes: 2,
          streak_frozen: userData.streak_frozen || false,
        });
        setLoading(false);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
        setLoading(false);
      }
    };
    fetchData();
  }, [session]);

  useEffect(() => {
    const fetchCalendarData = async () => {
      try {
        const calendarResponse = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/streak/calendar`,
          {
            headers: {
              Authorization: `Bearer ${session?.accessToken ?? ""}`,
            },
          }
        );
        if (calendarResponse.ok) {
          const calendarData = await calendarResponse.json();
          setTotalSessions(calendarData.summary.total_activities || 0);
          const transformedData: { date: string; count: number }[] = [];
          calendarData.weeks.forEach(
            (week: {
              days: {
                date: string;
                has_activity: boolean;
                activity_count: number;
              }[];
            }) => {
              week.days.forEach((day) => {
                if (day.has_activity) {
                  transformedData.push({
                    date: day.date,
                    count: day.activity_count,
                  });
                }
              });
            }
          );
          setCalendarData(transformedData);
        }
      } catch (err) {
        console.error("Error fetching calendar data:", err);
      }
    };
    if (session?.accessToken) fetchCalendarData();
  }, [session, selectedYear]);
  const handleSave = async () => {
    if (!session?.accessToken) return;
    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${session?.accessToken ?? ""}`,
          },
          body: JSON.stringify({
            name: user.name,
            settings: { bio: user.bio },
          }),
        }
      );
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to update user data");
      }
      const updatedUser = await response.json();
      setUser({
        name: updatedUser.name || session.user?.name || "User",
        email: updatedUser.email || session.user?.email || "",
        bio: updatedUser.settings?.bio || "",
        provider: updatedUser.provider || session.user?.provider || "N/A",
        created_at: updatedUser.created_at || new Date().toISOString(),
      });
      setStreakInfo({
        current_streak: updatedUser.current_streak || 0,
        longest_streak: updatedUser.longest_streak || 0,
        can_freeze: (updatedUser.freeze_count || 0) < 2,
        freeze_count: updatedUser.freeze_count || 0,
        max_freezes: 2,
        streak_frozen: updatedUser.streak_frozen || false,
      });
      setIsEditing(false);
      update({ user: { name: updatedUser.name } });
      setNotificationMessage("Profile updated successfully!");
      setPopupType("success");
      setShowNotificationPopup(true);
      setTimeout(() => setShowNotificationPopup(false), 3000);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
      setNotificationMessage(
        err instanceof Error ? err.message : "Unknown error"
      );
      setPopupType("error");
      setShowNotificationPopup(true);
      setTimeout(() => setShowNotificationPopup(false), 3000);
    }
  };

  const handleRegisterPushToken = async (
    token: string,
    platform: "ios" | "android"
  ) => {
    if (!session?.accessToken) return;
    try {
      if (!isNotificationsEnabled) {
        const response = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me/push-token`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${session?.accessToken ?? ""}`,
            },
            body: JSON.stringify({
              platform,
              token,
            }),
          }
        );
        if (response.ok) {
          setIsNotificationsEnabled(true);
          setNotificationMessage("Notifications enabled!");
          setPopupType("success");
          setShowNotificationPopup(true);
          setTimeout(() => setShowNotificationPopup(false), 3000);
        } else {
          const errorData = await response.json();
          setNotificationMessage(
            `Failed to register push token: ${errorData.error}`
          );
          setPopupType("error");
          setShowNotificationPopup(true);
          setTimeout(() => setShowNotificationPopup(false), 3000);
        }
      } else {
        setIsNotificationsEnabled(false);
        setNotificationMessage("Notifications disabled!");
        setPopupType("success");
        setShowNotificationPopup(true);
        setTimeout(() => setShowNotificationPopup(false), 3000);
      }
    } catch (err) {
      console.error("Error toggling notifications:", err);
      setNotificationMessage("An error occurred while toggling notifications.");
      setPopupType("error");
      setShowNotificationPopup(true);
      setTimeout(() => setShowNotificationPopup(false), 3000);
    }
  };

  useEffect(() => {
    const savedAvatar = localStorage.getItem("avatarImage");
    const savedBackground = localStorage.getItem("backgroundImage");

    if (savedAvatar) setAvatarImage(savedAvatar);
    if (savedBackground) {
      setBackgroundImage(savedBackground);
    } else {
      setBackgroundImage(
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5QkHAGP89CW8-TkQ-po-xygiSom_SCGe4WQ&s"
      );
    }
  }, []);

  useEffect(() => {
    if (avatarImage) {
      localStorage.setItem("avatarImage", avatarImage);
    } else {
      localStorage.removeItem("avatarImage");
    }
  }, [avatarImage]);

  useEffect(() => {
    if (backgroundImage) {
      localStorage.setItem("backgroundImage", backgroundImage);
    } else {
      localStorage.removeItem("backgroundImage");
    }
  }, [backgroundImage]);

  const achievements = [
    {
      title: "Week Warrior",
      description: "7-day learning streak",
      icon: <Activity className="h-5 w-5 text-green-600" />,
      color: "bg-green-50 border-green-200",
    },
    {
      title: "Grammar Pro",
      description: "Completed 35 grammar sessions",
      icon: <BookOpen className="h-5 w-5 text-blue-600" />,
      color: "bg-blue-50 border-blue-200",
    },
    {
      title: "Email Expert",
      description: "Drafted 10 professional emails",
      icon: <Mail className="h-5 w-5 text-purple-600" />,
      color: "bg-purple-50 border-purple-200",
    },
    {
      title: "Perfect Score",
      description: "100% on pronunciation test",
      icon: <Mic className="h-5 w-5 text-orange-600" />,
      color: "bg-orange-50 border-orange-200",
    },
  ];

  const handleAvatarChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatarImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleBackgroundChange = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setBackgroundImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleLogout = async () => {
    const refreshToken =
      (session?.user as { refreshToken?: string })?.refreshToken ||
      (session as { refreshToken?: string })?.refreshToken;

    if (!refreshToken) {
      signOut({ callbackUrl: "/" });
      return;
    }
    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/logout`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            refresh_token: refreshToken,
          }),
        }
      );
      if (!response.ok) throw new Error("Failed to logout");
      signOut({ callbackUrl: "/" });
    } catch (err) {
      console.error("Logout API error:", err);
      signOut({ callbackUrl: "/" });
    }
  };

  const handleFreezeStreak = async () => {
    if (!streakInfo.can_freeze) {
      setNotificationMessage("Freeze limit reached for this month.");
      setPopupType("error");
      setShowNotificationPopup(true);
      setTimeout(() => setShowNotificationPopup(false), 3000);
      return;
    }
    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/streak/freeze`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${session?.accessToken ?? ""}`,
          },
          body: JSON.stringify({
            reason: "User requested freeze",
          }),
        }
      );
      if (response.ok) {
        setNotificationMessage("Streak frozen successfully!");
        setPopupType("success");
        setShowNotificationPopup(true);
        setTimeout(() => setShowNotificationPopup(false), 3000);
        const userResponse = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`,
          {
            headers: {
              Authorization: `Bearer ${session?.accessToken ?? ""}`,
            },
          }
        );
        if (userResponse.ok) {
          const userData = await userResponse.json();
          setStreakInfo({
            current_streak: userData.current_streak || 0,
            longest_streak: userData.longest_streak || 0,
            can_freeze: (userData.freeze_count || 0) < 2,
            freeze_count: userData.freeze_count || 0,
            max_freezes: 2,
            streak_frozen: userData.streak_frozen || false,
          });
        }
      } else {
        const errorData = await response.json();
        setNotificationMessage(
          `Failed to freeze streak: ${errorData.error || "Unknown error"}`
        );
        setPopupType("error");
        setShowNotificationPopup(true);
        setTimeout(() => setShowNotificationPopup(false), 3000);
      }
    } catch (err) {
      console.error("Error freezing streak:", err);
      setNotificationMessage("An error occurred while freezing the streak.");
      setPopupType("error");
      setShowNotificationPopup(true);
      setTimeout(() => setShowNotificationPopup(false), 3000);
    }
  };

  const yearOptions = [];
  const currentYear = new Date().getFullYear();
  for (let i = -2; i <= 0; i++) {
    yearOptions.push(currentYear + i);
  }

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        !event.target ||
        !(event.target as Element).closest(".custom-dropdown")
      ) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  if (loading)
    return (
      <div className="fixed inset-0 bg-white flex items-center justify-center z-50">
        <div className="text-center">
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="mb-6"
          >
            <motion.img
              src="/images/mascot2.png"
              alt="Mascot"
              className="w-32 h-32 mx-auto"
              whileHover={{
                rotate: [0, -10, 10, 0],
                transition: { duration: 0.6 },
              }}
              whileTap={{ scale: 0.9, rotate: 15 }}
            />
          </motion.div>

          {/* Motivational Message with Cycling */}
          <motion.h2
            key={quote}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-2xl font-bold text-blue-900 mb-4"
          >
            {quote}
          </motion.h2>

          {/* Pulsing Dots Progress Indicator */}
          <div className="flex justify-center space-x-2">
            {[0, 1, 2].map((i) => (
              <motion.div
                key={i}
                animate={{ scale: [1, 1.2, 1] }}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  delay: i * 0.2,
                  ease: "easeInOut",
                }}
                className="w-4 h-4 bg-blue-400 rounded-full"
              />
            ))}
          </div>
        </div>
      </div>
    );
  if (error)
    return <div className="p-4 text-red-600 font-bold">Error: {error}</div>;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Centered Modal Popup */}
      {showNotificationPopup && (
        <div className="fixed inset-0  bg-gray-900/40 backdrop-blur-sm flex items-center justify-center z-50">
          <div
            className={`bg-white rounded-4xl shadow-lg p-6 max-w-sm w-full mx-4 flex flex-col items-center gap-2 ${
              popupType === "success"
                ? "border-2 border-green-500 text-2xl text-green-700"
                : "border-2 border-red-500 text-2xl text-red-700"
            }`}
          >
            {popupType === "success" ? (
              <>
                <img
                  src="/images/success.png"
                  alt="Success"
                  className="h-50 w-50"
                />
              </>
            ) : (
              <>
                <img
                  src="/images/error.png"
                  alt="Error"
                  className="h-50 w-50"
                />
              </>
            )}
            <span>{notificationMessage}</span>
            <button
              onClick={() => setShowNotificationPopup(false)}
              className="text-gray-600 hover:text-gray-800"
            >
              <XCircle className="h-8 w-8" />
            </button>
          </div>
        </div>
      )}

      <Header avatarImage={avatarImage ?? undefined} />

      <section className="relative">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20">
          <div
            className="relative -mt-16 bg-white rounded-xl shadow-sm border p-6 overflow-hidden"
            style={{
              backgroundImage: backgroundImage
                ? `url(${backgroundImage})`
                : "linear-gradient(to right, #ff7e5f, #feb47b)",
              backgroundSize: "cover",
              backgroundPosition: "center",
              backgroundRepeat: "no-repeat",
              minHeight: "220px",
              paddingTop: "8rem",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <button
              onClick={() => backgroundInputRef.current?.click()}
              className="absolute top-4 right-4 bg-white rounded-full p-2 shadow border hover:bg-gray-50 z-10"
              aria-label="Change background"
            >
              <Camera className="h-4 w-4 text-gray-600" />
            </button>
            <input
              type="file"
              ref={backgroundInputRef}
              onChange={handleBackgroundChange}
              accept="image/*"
              className="hidden"
            />

            <div className="relative z-20 mt-auto bg-white rounded-b-xl -mx-6 -mb-6 px-6 pt-2 pb-6">
              <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div className="flex items-center gap-4">
                  <div className="relative -mt-16">
                    <div
                      className="w-32 h-32 rounded-full bg-gradient-to-r from-green-500 to-blue-500 flex items-center justify-center text-white text-2xl font-bold bg-cover bg-center border-4 border-white shadow-md"
                      style={{
                        backgroundImage: avatarImage
                          ? `url(${avatarImage})`
                          : undefined,
                      }}
                    >
                      {!avatarImage &&
                        (user.name ? user.name.charAt(0).toUpperCase() : "U")}
                    </div>
                    <button
                      onClick={() => avatarInputRef.current?.click()}
                      className="absolute -bottom-1 -right-1 bg-white rounded-full p-1 shadow border hover:bg-gray-50 z-10"
                      aria-label="Change avatar"
                    >
                      <Camera className="h-4 w-4 text-gray-600" />
                    </button>
                  </div>
                  <input
                    type="file"
                    ref={avatarInputRef}
                    onChange={handleAvatarChange}
                    accept="image/*"
                    className="hidden"
                  />
                  <div>
                    {isEditing ? (
                      <div className="space-y-2 mt-2">
                        <input
                          type="text"
                          value={user.name}
                          onChange={(e) =>
                            setUser({ ...user, name: e.target.value })
                          }
                          className="text-2xl font-bold text-gray-900 border-b border-gray-300 focus:outline-none focus:border-blue-500 w-full"
                          placeholder="Username"
                        />
                        <input
                          type="email"
                          value={user.email}
                          onChange={(e) =>
                            setUser({ ...user, email: e.target.value })
                          }
                          className="text-sm text-gray-600 border-b border-gray-300 focus:outline-none focus:border-blue-500 w-full"
                          placeholder="Email"
                          disabled
                        />
                      </div>
                    ) : (
                      <div className="mt-2">
                        <h1 className="text-2xl font-bold text-gray-900">
                          {user.name}
                        </h1>
                        <div className="text-gray-600 flex flex-wrap items-center gap-x-4 gap-y-1 text-sm mt-1">
                          <span className="inline-flex items-center">
                            <MapPin className="h-4 w-4 mr-1" /> Abeba Abeba, AA
                          </span>
                          <span className="inline-flex items-center">
                            <Calendar className="h-4 w-4 mr-1" /> Joined{" "}
                            {new Date(user.created_at).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setIsEditing(!isEditing)}
                    className="px-2 py-0.5 rounded-lg bg-[#337fa1] text-white inline-flex items-center gap-2 hover:bg-gray-400"
                  >
                    <Edit3 className="h-4 w-4" />{" "}
                    {isEditing ? "Cancel Edit" : "Edit Profile"}
                  </button>
                  {isEditing && (
                    <button
                      onClick={handleSave}
                      className="px-4 py-0.5 rounded-lg bg-[#337fa1] text-white inline-flex items-center gap-2 hover:bg-[#3e5b6b]"
                    >
                      Save Changes
                    </button>
                  )}
                  <button
                    onClick={() =>
                      handleRegisterPushToken("your_fcm_token_here", "ios")
                    } // Replace with actual token/platform
                    className={`relative w-10 h-10 rounded-full border-2 flex items-center justify-center transition-colors ${
                      isNotificationsEnabled
                        ? "bg-gradient-to-b from-blue-500 to-[#337fa1] border-blue-400 text-white"
                        : "border-gray-300 text-blue-600 hover:border-blue-500 hover:text-blue-500"
                    }`}
                    title={
                      isNotificationsEnabled
                        ? "Disable Notifications"
                        : "Enable Notifications"
                    }
                  >
                    <Bell className="h-5 w-5" />
                    {notificationCount > 0 && (
                      <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                        {notificationCount > 99 ? "99+" : notificationCount}
                      </span>
                    )}
                  </button>
                </div>
              </div>
              <div className="mt-4">
                {isEditing ? (
                  <textarea
                    value={user.bio}
                    onChange={(e) => setUser({ ...user, bio: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 text-black font-italic"
                    rows={3}
                    placeholder="Bio"
                  />
                ) : (
                  <p className="text-gray-700 italic">{user.bio}</p>
                )}
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-6">
                <div className="bg-gray-50 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-gray-900">2</div>
                  <div className="text-sm text-gray-600">Level</div>
                </div>
                <div className="bg-gray-50 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-gray-900">
                    {totalSessions}
                  </div>
                  <div className="text-sm text-gray-600">Sessions</div>
                </div>
                <div className="bg-gray-50 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-gray-900">
                    {streakInfo.longest_streak}
                  </div>
                  <div className="text-sm text-gray-600">Longest Streak</div>
                </div>
                <div className="bg-gray-50 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-gray-900">
                    {streakInfo.current_streak}
                  </div>
                  <div className="text-sm text-gray-600 flex items-center justify-center gap-1">
                    <Flame
                      className={`h-4 w-4 ${
                        streakInfo.current_streak > 0 ? "fill-orange-400" : ""
                      } border-amber-700 text-orange-500`}
                    />{" "}
                    Day Streak
                  </div>
                </div>
              </div>
              <div className="mt-6 border-b flex items-center gap-6 text-sm">
                {(["overview", "activity", "awards"] as const).map((t) => (
                  <button
                    key={t}
                    onClick={() => setActiveTab(t)}
                    className={`py-3 -mb-px border-b-2 ${
                      activeTab === t
                        ? "border-green-600 text-green-700 font-medium"
                        : "border-transparent text-gray-600 hover:text-gray-900"
                    }`}
                  >
                    {t[0].toUpperCase() + t.slice(1)}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 pt-10 grid lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          {activeTab === "overview" && (
            <>
              <div className="space-y-6">
                <section className="bg-white rounded-xl shadow-sm border p-6">
                  <div className="flex items-center justify-between mb-1">
                    <h2 className="text-lg font-semibold text-gray-900">
                      Learning Streak
                    </h2>
                    <div className="flex items-center gap-4">
                      <button
                        onClick={handleFreezeStreak}
                        disabled={!streakInfo.can_freeze}
                        className={`px-4 py-1 rounded-full shadow-md ${
                          streakInfo.can_freeze
                            ? "bg-[#337fa1] text-white hover:bg-[#526b76]"
                            : "bg-gray-400 text-gray-700 cursor-not-allowed"
                        }`}
                      >
                        Freeze Streak{" "}
                        {streakInfo.can_freeze
                          ? ""
                          : `(Used ${streakInfo.freeze_count}/${streakInfo.max_freezes})`}
                      </button>
                      <div className="relative custom-dropdown">
                        <button
                          onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                          className="px-3 py-1 border border-gray-300 rounded-md text-sm bg-white text-stone-800 flex items-center justify-between w-20 focus:outline-none focus:ring-2 focus:ring-[#cf9f57] focus:border-transparent"
                        >
                          {selectedYear}
                          <svg
                            className={`w-4 h-4 ml-1 transition-transform ${
                              isDropdownOpen ? "rotate-180" : ""
                            }`}
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M19 9l-7 7-7-7"
                            />
                          </svg>
                        </button>
                        {isDropdownOpen && (
                          <ul className="absolute top-full mt-1 w-20 bg-white border border-gray-300 rounded-md shadow-lg z-10">
                            {yearOptions.map((year) => (
                              <li
                                key={year}
                                onClick={() => {
                                  setSelectedYear(year);
                                  setIsDropdownOpen(false);
                                }}
                                className="px-3 py-1 text-stone-800 hover:bg-gray-100 cursor-pointer"
                              >
                                {year}
                              </li>
                            ))}
                          </ul>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <p className="text-sm text-gray-600">Current Streak</p>
                      <p className="text-2xl font-bold text-green-600">
                        {streakInfo.current_streak} days
                      </p>
                    </div>
                  </div>
                  <CalendarHeatmap
                    startDate={new Date(selectedYear, 0, 1)}
                    endDate={new Date(selectedYear, 11, 31)}
                    values={calendarData}
                    classForValue={(value) => {
                      if (!value || typeof value.count !== "number")
                        return "color-empty";
                      return `color-scale-${Math.min(value.count, 4)}`;
                    }}
                    tooltipDataAttrs={(value) => {
                      return {
                        "data-tooltip":
                          value && typeof value.count === "number"
                            ? `${value.date}: ${value.count} activities`
                            : "",
                      } as Record<string, string>;
                    }}
                  />
                </section>
                <section className="bg-white rounded-xl shadow-sm border p-6">
                  <h2 className="text-lg font-semibold text-gray-900 mb-4">
                    Achievements & Badges
                  </h2>
                  <div className="grid sm:grid-cols-2 gap-4">
                    {achievements.map((a, i) => (
                      <div
                        key={i}
                        className={`flex items-start gap-3 p-4 rounded-lg border ${a.color}`}
                      >
                        <div className="mt-0.5">{a.icon}</div>
                        <div>
                          <div className="font-medium text-gray-900">
                            {a.title}
                          </div>
                          <div className="text-sm text-gray-600">
                            {a.description}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </section>

                <section className="bg-white rounded-xl shadow-sm border p-6">
                  <h2 className="text-lg font-semibold text-gray-900 mb-4">
                    Recent Activity
                  </h2>
                  <ul className="space-y-3">
                    <li className="flex items-start gap-3 p-3 rounded-lg bg-green-50">
                      <Award className="h-5 w-5 text-green-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-900">
                          Mock Interview Completed
                        </div>
                        <div className="text-sm text-gray-600">
                          Frontend Developer role — Score 89%
                        </div>
                      </div>
                      <span className="text-xs text-gray-500 ml-auto">
                        2 hours ago
                      </span>
                    </li>
                    <li className="flex items-start gap-3 p-3 rounded-lg bg-blue-50">
                      <BookOpen className="h-5 w-5 text-blue-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-900">
                          Email Draft Generated
                        </div>
                        <div className="text-sm text-gray-600">
                          Job application for remote position
                        </div>
                      </div>
                      <span className="text-xs text-gray-500 ml-auto">
                        1 day ago
                      </span>
                    </li>
                  </ul>
                </section>
              </div>
            </>
          )}

          {activeTab === "activity" && (
            <section className="bg-white rounded-xl shadow-sm border p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Activity Log
              </h2>
              <ul className="space-y-3">
                <li className="flex items-center justify-between p-3 rounded-lg border">
                  <div className="flex items-center gap-3 text-gray-700">
                    <Clock className="h-4 w-4" /> Practiced pronunciation for 25
                    minutes
                  </div>
                  <span className="text-xs text-gray-500">Today 10:20</span>
                </li>
                <li className="flex items-center justify-between p-3 rounded-lg border">
                  <div className="flex items-center gap-3 text-gray-700">
                    <BookOpen className="h-4 w-4" /> Completed grammar session
                    on tenses
                  </div>
                  <span className="text-xs text-gray-500">Yesterday</span>
                </li>
              </ul>
            </section>
          )}

          {activeTab === "awards" && (
            <section className="bg-white rounded-xl shadow-sm border p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Awards
              </h2>
              <div className="grid sm:grid-cols-2 gap-4">
                <div className="p-4 rounded-lg border bg-yellow-50">
                  <div className="flex items-center gap-3 mb-1">
                    <Award className="h-5 w-5 text-yellow-600" />
                    <span className="font-medium text-gray-900">
                      Consistency Champion
                    </span>
                  </div>
                  <p className="text-sm text-gray-700">
                    Maintained a 30-day active streak
                  </p>
                </div>
                <div className="p-4 rounded-lg border bg-blue-50">
                  <div className="flex items-center gap-3 mb-1">
                    <Star className="h-5 w-5 text-blue-600" />
                    <span className="font-medium text-gray-900">
                      Top 100 Rank
                    </span>
                  </div>
                  <p className="text-sm text-gray-700">
                    Reached top 100 globally this week
                  </p>
                </div>
              </div>
            </section>
          )}
        </div>
        <aside className="space-y-6">
          <section className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Quick Stats</h3>
            <ul className="space-y-3 text-sm text-gray-700">
              <li className="flex items-center justify-between">
                <span>Current Level</span>
                <span className="font-medium">Intermediate</span>
              </li>
              <li className="flex items-center justify-between">
                <span>Best Streak</span>
                <span className="font-medium">
                  {streakInfo.longest_streak} days
                </span>
              </li>
              <li className="flex items-center justify-between">
                <span>Rank</span>
                <span className="font-medium">#87</span>
              </li>
            </ul>
          </section>

          <section className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Contact Info</h3>
            <ul className="space-y-3 text-sm text-gray-700">
              <li className="flex items-center gap-3">
                <Mail className="h-4 w-4 text-gray-500" />
                <span>{user.email}</span>
              </li>

              <li className="flex items-center gap-3">
                <Globe className="h-4 w-4 text-gray-500" />
                <span>www.lissanai.com</span>
              </li>
            </ul>
          </section>
          <section className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="font-semibold text-gray-900 mb-2">Explore</h3>
            <div className="flex flex-col gap-2">
              <Link
                href="/dashboard"
                className="px-4 py-2 rounded-lg border text-gray-700 hover:bg-gray-50 inline-flex items-center gap-2"
              >
                <Activity className="h-4 w-4" /> Dashboard
              </Link>
            </div>
          </section>
        </aside>
      </main>

      <Footer />
    </div>
  );
}