import { FiFacebook, FiTwitter, FiLinkedin } from "react-icons/fi";

const footerSections = {
  features: ["Mock Interviews", "Email Drafting", "Pronunciation Coach", "Grammar Check"],
  company: ["About Us", "Careers", "Blog", "Contact"],
  support: ["Help Center", "Privacy Policy", "Terms of Service"],
};

export default function Footer() {
  return (
    <footer className="bg-[#1e1e1e] py-16 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
          <div className="md:col-span-2 lg:col-span-1">
            <div className="flex items-center space-x-3 mb-6">
              <div className="bg-gradient-to-r from-[#3f72af] to-[#a0e7e5] rounded-lg w-10 h-10 flex items-center justify-center">
                <span className="text-[#112d4e] font-bold text-xl">L</span>
              </div>
              <span className="text-xl font-bold text-white">LissanAI</span>
            </div>
            <p className="mb-6 pr-4">
              Empowering Ethiopians to achieve global career success through AI-powered English coaching.
            </p>
            <div className="flex space-x-4">
              <a href="#" aria-label="Facebook" className="hover:text-white"><FiFacebook size={24} /></a>
              <a href="#" aria-label="Twitter" className="hover:text-white"><FiTwitter size={24} /></a>
              <a href="#" aria-label="LinkedIn" className="hover:text-white"><FiLinkedin size={24} /></a>
            </div>
          </div>
          {Object.entries(footerSections).map(([title, links]) => (
            <div key={title}>
              <h3 className="text-lg font-bold text-white mb-4 capitalize">{title}</h3>
              <ul className="space-y-3">
                {links.map((item) => (
                  <li key={item}>
                    <a href="#" className="hover:text-white transition-colors">{item}</a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="border-t border-gray-700 pt-8">
          <p className="text-center text-gray-400">
            © {new Date().getFullYear()} LissanAI. All rights reserved. Made with ❤️ by A2SVIANS
          </p>
        </div>
      </div>
    </footer>
  );
}