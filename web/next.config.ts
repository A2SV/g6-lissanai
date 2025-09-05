import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/((?!auth).*)", // Exclude /api/auth/* from proxy
        destination: "https://lissan-ai-backend-dev.onrender.com/api/:path*",
      },
    ];
  },
};

export default nextConfig;
