
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client"

import { useState, useEffect, Suspense } from "react"
import { useSearchParams } from "next/navigation"
import Image from "next/image"
import Link from "next/link"
import { FiCheck, FiCopy, FiRefreshCw, FiSend, FiZap, FiPlusCircle } from "react-icons/fi"
import { FaWandMagicSparkles } from "react-icons/fa6";
import toast, { Toaster } from "react-hot-toast"
import { IEmailProcessResponse } from "@/types"
import Header from "@/components/Header"

// This component contains the core interactive logic
function WritingForm() {
  const searchParams = useSearchParams()
  const initialText = searchParams.get("text")

  const [inputText, setInputText] = useState("")
  const [improvedText, setImprovedText] = useState<IEmailProcessResponse | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)


  useEffect(() => {
    if (initialText) {
      setInputText(initialText)
    }
  }, [initialText])

  const handleClear = () => {
    setInputText("")
    setImprovedText(null)
  }

  const handleAnalyze = async () => {
    if (!inputText.trim()) {
      toast.error("Please enter the text you want to improve.");
      return;
    }

    setIsAnalyzing(true)
    setImprovedText(null) 
    const loadingToast = toast.loading("LissanAI is analyzing your text...")

    try {
      const response = await fetch('/api/email/write', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: inputText,
        }),
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || "Something went wrong.");
      }

      const data: IEmailProcessResponse = result;
      setImprovedText(data); 
      toast.success("Your text has been improved!");

    } catch (error: any) {
      console.error("Failed to improve text:", error);
      toast.error(error.message || "Failed to improve text.");
    } finally {
      setIsAnalyzing(false)
      toast.dismiss(loadingToast)
    }
  }
  
  const handleCopyImprovedEmail = () => {
    if (!improvedText) return;
    const fullEmail = `Subject: ${improvedText.subject}\n\n${improvedText.body}`;
    navigator.clipboard.writeText(fullEmail);
    toast.success("Improved email copied!");
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
      
      <div className="bg-white rounded-lg border border-green-200 shadow-sm p-6">
        <h2 className="text-md font-semibold text-gray-800 flex items-center gap-2 mb-1"><FiPlusCircle /> Your English Text</h2>
        <p className="text-sm text-gray-500 mb-4">Post your English text here and well help improve it</p>

        <textarea
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="Enter your text here or generate it from the previous page..."
          className="w-full h-48 p-3 bg-gray-50 border border-gray-200 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-teal-500"
        />

        <div className="flex space-x-3 mt-4">
          <button
            onClick={handleAnalyze}
            disabled={isAnalyzing || !inputText.trim()}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 disabled:opacity-50 font-semibold"
          >
            {isAnalyzing ? <FiRefreshCw className="animate-spin" /> : <FiZap />}
            <span>{isAnalyzing ? "Analyzing..." : "Check and Improve"}</span>
          </button>
          <button
            onClick={handleClear}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium"
          >
            Clear
          </button>
        </div>
      </div>

      
      <div className="bg-white rounded-lg border border-green-200 shadow-sm p-6">
        <h2 className="text-md font-semibold text-gray-800 flex items-center gap-2 mb-4"><FiCheck /> AI-Powered Improvements</h2>
        
        {isAnalyzing ? (
          <div className="flex items-center justify-center h-full text-gray-500">
              <p>Analyzing and improving your text...</p>
          </div>
        ) : improvedText ? (
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-700">Suggested Subject</label>
              <div className="mt-1 p-3 bg-gray-50 border rounded-md text-sm text-gray-800 font-semibold">
                {improvedText.subject}
              </div>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-700">Improved Email Body</label>
              <div className="mt-1 p-3 bg-gray-50 border rounded-md text-sm text-gray-800 h-48 overflow-y-auto">
                <pre className="whitespace-pre-wrap font-sans">{improvedText.body}</pre>
              </div>
            </div>
            <button
              onClick={handleCopyImprovedEmail}
              className="flex items-center space-x-2 text-teal-600 hover:text-teal-800 font-medium"
            >
              <FiCopy className="w-4 h-4" />
              <span>Copy Improved Email</span>
            </button>
          </div>
        ) : (
          <div className="flex items-center justify-center h-full text-gray-500">
            <p>Improvements will appear here after you analyze your text.</p>
          </div>
        )}
      </div>
    </div>
  )
}


export default function WritingAssistantPage() {
  return (
    <div className="min-h-screen bg-[#F9FAFB]">
      <Toaster position="top-center" />
      <Header/>

      {/* Main Content */}
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
          <Link href="/email/drafting" className="flex-1 flex items-center justify-center gap-2 text-gray-600 px-4 py-2 font-semibold hover:bg-white hover:shadow rounded-md transition-all">
            <FaWandMagicSparkles />
            Generate Email 
          </Link>
          <button className="flex-1 flex items-center justify-center gap-2 bg-teal-600 text-white px-4 py-2 rounded-md shadow font-semibold transition-all">
            <FiZap />
            Improve English Text
          </button>
        </div>
        

        <Suspense fallback={<div className="text-center p-8">Loading Editor...</div>}>
          <WritingForm />
        </Suspense>

      </main>
    </div>
  )
}