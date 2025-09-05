
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client"

import { useState, useRef, useEffect } from "react"
import Image from "next/image"
import Link from "next/link";
import { FiCopy, FiRefreshCw, FiSend, FiCheck, FiZap, FiStar, FiChevronDown, FiPlusCircle, FiXCircle } from "react-icons/fi"
import { FaWandMagicSparkles } from "react-icons/fa6";
import toast, { Toaster } from "react-hot-toast";
import { IEmailProcessResponse } from "@/types";
import Header from "@/components/Header";

export default function EmailDraftingPage() {
  
  const [userInput, setUserInput] = useState("")
  const [generatedEmail, setGeneratedEmail] = useState("")
  const [isGenerating, setIsGenerating] = useState(false)
  
  const [tone, setTone] = useState("Professional");
  const [isToneDropdownOpen, setIsToneDropdownOpen] = useState(false);
  const toneDropdownRef = useRef<HTMLDivElement>(null);
  const toneOptions = ["Professional", "Casual", "Friendly", "Direct"];

  const [emailType, setEmailType] = useState("Meeting Request")
  const [isEmailDropdownOpen, setIsEmailDropdownOpen] = useState(false);
  const emailDropdownRef = useRef<HTMLDivElement>(null);

  const emailOptions = [
      { label: "Job Application", category: "Career" },
      { label: "Application Follow-up", category: "Career" },
      { label: "Meeting Request", category: "Business" },
      { label: "Thank You Email", category: "Professional" },
      { label: "General Inquiry", category: "Business" },
  ];
  
  const selectedEmailOption = emailOptions.find(opt => opt.label === emailType) || emailOptions[0];

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (emailDropdownRef.current && !emailDropdownRef.current.contains(event.target as Node)) {
        setIsEmailDropdownOpen(false);
      }
      if (toneDropdownRef.current && !toneDropdownRef.current.contains(event.target as Node)) {
        setIsToneDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [emailDropdownRef, toneDropdownRef]);
  
  const handleGenerateEmail = async () => {
    if (!userInput.trim()) {
      toast.error("Please describe what you want to write about.");
      return;
    }

    setIsGenerating(true);
    const loadingToast = toast.loading("LissanAI is drafting your email...");

    try {
      const prompt = `
        Email Type: ${emailType}
        Tone: ${tone}
        User's specific request: ${userInput}
      `;

      const response = await fetch('/api/email/draft', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: prompt,
          type: 'GENERATE',
          template_type: emailType,
          tone: tone,
        }),
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || "Something went wrong.");
      }

      const data: IEmailProcessResponse = result;
       setGeneratedEmail(data.body); 
      toast.success("Your email has been generated!");

    } catch (error: any) {
      console.error("Failed to generate email:", error);
      toast.error(error.message || "Failed to generate email.");
    } finally {
      setIsGenerating(false);
      toast.dismiss(loadingToast);
    }
  };

  const handleClear = () => {
    setUserInput("")
    setGeneratedEmail("")
  }

  const handleCopyEmail = () => {
    if (!generatedEmail) {
        toast.error("Nothing to copy!");
        return;
    }
    navigator.clipboard.writeText(generatedEmail)
    toast.success("Email copied to clipboard!");
  }

  return (
    <div className="min-h-screen bg-[#F9FAFB]">
      <Toaster position="top-center" />
      <Header/>

      <main className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        
        <div className="text-center mb-8">
          <Image
            src="/images/mascot.png"
            alt="LissanAI Email Assistant"
            width={80}
            height={80}
            className="w-20 h-20 rounded-full object-contain bg-teal-50 p-1 mx-auto mb-4 border-4 border-white shadow-lg"
          />
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 flex items-center justify-center gap-1 sm:gap-2">
            <FiSend /> 
            <span>Email Writing Assistant</span>
          </h1>
        </div>

        <div className="bg-blue-50/60 border border-blue-200 rounded-lg p-4 flex flex-col items-center gap-4 mb-8">
            <div className="flex items-center gap-3">
                <Image 
                    src="/images/mascot.png" 
                    alt="Mascot" 
                    width={40} 
                    height={40} 
                    className="w-10 h-10 rounded-full object-contain bg-white" 
                />
                <p className="text-gray-700 font-medium text-center sm:text-left">Great work! Your email looks professional and polite. Ready to send?</p>
            </div>
            <div className="w-full grid grid-cols-3 gap-4">
                <div className="bg-white rounded-lg shadow-sm border-t-4 border-green-400 p-2 text-center">
                    <p className="font-bold text-lg text-green-500">14</p>
                    <p className="text-xs text-gray-500">Emails Written</p>
                </div>
                <div className="bg-white rounded-lg shadow-sm border-t-4 border-yellow-400 p-2 text-center">
                    <p className="font-bold text-lg text-yellow-500">3</p>
                    <p className="text-xs text-gray-500">Day Streak</p>
                </div>
                <div className="bg-white rounded-lg shadow-sm border-t-4 border-purple-400 p-2 text-center">
                    <p className="font-bold text-lg text-purple-500">+15</p>
                    <p className="text-xs text-gray-500">XP Today</p>
                </div>
            </div>
        </div>

        <div className="flex justify-center items-center bg-gray-100 p-1 rounded-lg max-w-md mx-auto mb-8">
          <button className="flex-1 flex items-center justify-center gap-2 bg-teal-600 text-white px-4 py-2 rounded-md shadow font-semibold transition-all">
            <FaWandMagicSparkles />
            Generate Email 
          </button>
          
          <Link
            href="/email/writing"
            className="flex-1 flex items-center justify-center gap-2 text-gray-600 px-4 py-2 font-semibold transition-all rounded-md hover:bg-white hover:shadow"
          >
            <FiZap />
            Improve English Text
          </Link>
          
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            {/* Email Type Card */}
            <div className="bg-white border border-green-200 rounded-lg shadow-sm p-6">
                <h2 className="text-md font-semibold text-gray-800 mb-1">Email Type</h2>
                <p className="text-sm text-gray-500 mb-4">Choose the type of email you want to write</p>
                <div className="relative" ref={emailDropdownRef}>
                    <button 
                      onClick={() => setIsEmailDropdownOpen(!isEmailDropdownOpen)}
                      className="w-full border border-gray-300 rounded-lg p-3 flex justify-between items-center bg-white cursor-pointer text-left"
                    >
                        <span className="font-medium text-gray-700">{selectedEmailOption.label}</span>
                        <div className="flex items-center gap-2">
                            <span className="text-sm text-gray-500 bg-gray-100 px-2 py-0.5 rounded">{selectedEmailOption.category}</span>
                            <FiChevronDown className={`text-gray-400 transition-transform ${isEmailDropdownOpen ? 'rotate-180' : ''}`} />
                        </div>
                    </button>
                    {isEmailDropdownOpen && (
                        <div className="absolute top-full mt-2 w-full bg-white border border-gray-200 rounded-lg shadow-lg z-10">
                            <ul>
                                {emailOptions.map((option) => (
                                    <li 
                                      key={option.label}
                                      onClick={() => {
                                          setEmailType(option.label);
                                          setIsEmailDropdownOpen(false);
                                      }}
                                      className="flex justify-between items-center p-3 hover:bg-gray-50 cursor-pointer"
                                    >
                                        <div className="flex items-center gap-2">
                                            <span className="font-medium text-gray-700">{option.label}</span>
                                            <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded">{option.category}</span>
                                        </div>
                                        {emailType === option.label && <FiCheck className="text-blue-600" />}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>
                <div className="bg-gray-50 rounded-lg p-3 mt-4">
                    <p className="text-sm font-semibold text-gray-600">Example:</p>
                    <p className="text-sm text-gray-500">I would like to schedule a meeting to discuss the project requirements</p>
                </div>
            </div>
            
            {/* Tone Card */}
            <div className="bg-white border border-green-200 rounded-lg shadow-sm p-6">
                <h2 className="text-md font-semibold text-gray-800 mb-1">Tone</h2>
                <p className="text-sm text-gray-500 mb-4">Select the tone of the email</p>
                 <div className="relative" ref={toneDropdownRef}>
                    <button 
                      onClick={() => setIsToneDropdownOpen(!isToneDropdownOpen)}
                      className="w-full border border-gray-300 rounded-lg p-3 flex justify-between items-center bg-white cursor-pointer text-left"
                    >
                        <span className="font-medium text-gray-700">{tone}</span>
                        <FiChevronDown className={`text-gray-400 transition-transform ${isToneDropdownOpen ? 'rotate-180' : ''}`} />
                    </button>
                    {isToneDropdownOpen && (
                        <div className="absolute top-full mt-2 w-full bg-white border border-gray-200 rounded-lg shadow-lg z-10">
                            <ul>
                                {toneOptions.map((option) => (
                                    <li 
                                      key={option}
                                      onClick={() => {
                                          setTone(option);
                                          setIsToneDropdownOpen(false);
                                      }}
                                      className="flex justify-between items-center p-3 hover:bg-gray-50 cursor-pointer"
                                    >
                                        <span className="font-medium text-gray-700">{option}</span>
                                        {tone === option && <FiCheck className="text-blue-600" />}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>
                <div className="bg-gray-50 rounded-lg p-3 mt-4">
                    <p className="text-sm font-semibold text-gray-600">Example:</p>
                    <p className="text-sm text-gray-500">Choosing a casual tone might start with Hey team instead of Dear Sir/Madam.</p>
                </div>
            </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Left Pane - Input */}
          <div className="bg-white rounded-lg border border-green-200 shadow-sm p-6">
            <h2 className="text-md font-semibold text-gray-800 flex items-center gap-2 mb-1"><FiPlusCircle /> Describe in Amharic/English</h2>
            <p className="text-sm text-gray-500 mb-4">Tell me what you want to write in Amharic, and Ill create a professional English email for you!</p>
            <textarea
              value={userInput}
              onChange={(e) => setUserInput(e.target.value)}
              placeholder="e.g., Ask my manager for a follow-up meeting about the Q3 report next Tuesday."
              className="w-full h-52 p-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 resize-none"
            />
            <div className="flex items-center justify-between mt-4">
              <button
                onClick={handleGenerateEmail}
                disabled={isGenerating}
                className="flex items-center gap-2 bg-teal-600 text-white px-4 py-2 rounded-lg hover:bg-teal-700 disabled:opacity-50 font-semibold transition-colors"
              >
                {isGenerating ? <FiRefreshCw className="animate-spin" /> : <FiSend />}
                <span>{isGenerating ? "Creating..." : "Create Email (+25 XP)"}</span>
              </button>
              <button onClick={handleClear} className="flex items-center gap-2 text-gray-500 hover:text-gray-700 font-medium">
                <FiXCircle />
                Clear
              </button>
            </div>
          </div>

          {/* Right Pane - Generated Email */}
          <div className="bg-white rounded-lg border border-green-200 shadow-sm p-6">
            <h2 className="text-md font-semibold text-gray-800 flex items-center gap-2 mb-4">
                <FiCheck /> Professional English Email
            </h2>
            <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 h-64 overflow-y-auto">
              {isGenerating ? (
                  <div className="flex items-center justify-center h-full text-gray-500">Generating...</div>
              ) : generatedEmail ? (
                  <pre className="whitespace-pre-wrap text-sm text-gray-700 font-sans">{generatedEmail}</pre>
              ) : (
                <div className="flex items-center justify-center h-full text-gray-400 text-sm">
                  Your generated email will appear here.
                </div>
              )}
            </div>
            <div className="flex items-center justify-between mt-4">
              <button
                onClick={handleCopyEmail}
                className="flex items-center gap-2 text-gray-600 hover:text-gray-800 font-medium"
              >
                <FiCopy />
                <span>Copy Email</span>
              </button>
              <Link
                href={{
                  pathname: '/email/writing',
                  query: { text: generatedEmail },
                }}
                onClick={(e) => !generatedEmail && e.preventDefault()}
                aria-disabled={!generatedEmail}
                className={`flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold transition-colors ${
                  !generatedEmail 
                    ? 'opacity-50 cursor-not-allowed' 
                    : 'hover:bg-blue-700'
                }`}
              >
                <FiZap />
                <span>Professional Quality</span>
              </Link>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-green-200 shadow-sm p-6">
          <div className="flex items-center gap-3 mb-6">
            <Image 
                src="/images/mascot.png" 
                alt="LissanAI Tips" 
                width={40} 
                height={40} 
                className="w-10 h-10 rounded-full object-contain bg-white" 
            />
            <h2 className="text-lg font-semibold text-gray-800">Lissans Email Writing Tips</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
            <div>
              <h3 className="font-semibold text-gray-700 mb-3">What to include in Amharic:</h3>
              <ul className="space-y-3">
                <li className="flex items-start gap-3"><FiCheck className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Purpose of the email (job application, meeting request, etc.)</span></li>
                <li className="flex items-start gap-3"><FiCheck className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Your specific situation or background</span></li>
                <li className="flex items-start gap-3"><FiCheck className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">What action you want the recipient to take</span></li>
                <li className="flex items-start gap-3"><FiCheck className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Any deadlines or time constraints</span></li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold text-gray-700 mb-3">Lissan will automatically:</h3>
              <ul className="space-y-3">
                <li className="flex items-start gap-3"><FiStar className="w-5 h-5 text-yellow-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Use professional and polite language</span></li>
                <li className="flex items-start gap-3"><FiStar className="w-5 h-5 text-yellow-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Structure the email properly</span></li>
                <li className="flex items-start gap-3"><FiStar className="w-5 h-5 text-yellow-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Add appropriate greetings and closings</span></li>
                <li className="flex items-start gap-3"><FiStar className="w-5 h-5 text-yellow-500 mt-0.5 flex-shrink-0" /><span className="text-sm text-gray-600">Ensure grammatically correct English</span></li>
              </ul>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}