"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  CheckCircle,
  Copy,
  Download,
  Lightbulb,
  AlertCircle,
  Loader2,
} from "lucide-react";
import Header from "@/components/Header";
import Image from "next/image";

export default function GrammarCoachPage() {
  const [activeTab, setActiveTab] = useState<"grammar" | "examples">("grammar");
  const [text, setText] = useState("");
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisResults, setAnalysisResults] = useState<any>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [selectedLang, setSelectedLang] = useState<"english" | "amharic">(
    "english"
  );

  const handleDownload = () => {
    if (!analysisResults?.improvedText) return;
    const element = document.createElement("a");
    const file = new Blob([analysisResults.improvedText], {
      type: "text/plain",
    });
    element.href = URL.createObjectURL(file);
    element.download = "improved-text.txt";
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };

  const handleCopy = () => {
    if (!analysisResults?.improvedText) return;
    navigator.clipboard.writeText(analysisResults.improvedText);
  };

  const handleApplyFix = (issue: any) => {
    const regex = new RegExp(issue.original, "gi");
    const newText = text.replace(regex, issue.suggestion);
    setText(newText);
    setAnalysisResults(null);
  };

  const handleAnalyze = async () => {
    setErrorMsg(null);
    if (!text.trim()) return;
    setActiveTab("grammar");
    setIsAnalyzing(true);

    try {
      const response = await fetch(`/api/grammar/check`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_GRAMMAR_API_TOKEN}`,
        },
        body: JSON.stringify({ text }),
      });
      const data = await response.json();

      if (!response.ok) {
        setErrorMsg(
          data?.error || "Unable to analyze at this time. Please try again."
        );
        setAnalysisResults(null);
        setIsAnalyzing(false);
        return;
      }

      const issues =
        (data.corrections ?? []).map((correction: any) => ({
          type: "Grammar",
          message: correction.explanation,
          suggestion: correction.corrected_phrase,
          original: correction.original_phrase,
        })) || [];

      setAnalysisResults({
        improvedText: data.corrected_text ?? text,
        issues,
        issuesFound: issues.length,
        score:
          data.score ?? (issues.length === 0 ? 100 : 85 - issues.length * 5),
        wordCount: text.split(" ").filter((word) => word.length > 0).length,
        readability: data.readability ?? "Good",
        writingTips: data.writingTips ?? [
          "Read your text aloud to catch errors",
          "Use active voice when possible",
          "Keep sentences clear and concise",
          "Check subject-verb agreement",
        ],
      });
    } catch (error) {
      setErrorMsg("Unable to analyze at this time. Please try again.");
      setAnalysisResults(null);
    }
    setIsAnalyzing(false);
  };

  type SampleText = {
    id: number;
    title: string;
    text:
      | string
      | {
          english?: string;
          amharic?: string;
          [key: string]: string | undefined;
        };
  };

  const sampleTexts: SampleText[] = [
    {
      id: 1,
      title: "Load Sample 1",
      text: "I am writing to apply for the position of software developer at your company. I have 3 years experience in programming and I'm very excited about this opportunity.",
    },
    {
      id: 2,
      title: "Load Sample 2",
      text: "Dear hiring manager, I want to introduce myself as a candidate for the marketing role. I has worked in various companies and learned many skills.",
    },
    {
      id: 3,
      title: "Load Sample 3",
      text: "Thank you for considering my application. I am confident that my background and enthusiasm makes me a strong candidate for this position.",
    },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tab Navigation */}
        <div className="flex justify-center mb-8">
          <div className="flex bg-white rounded-lg p-1 shadow-sm border">
            <button
              onClick={() => setActiveTab("grammar")}
              className={`px-6 py-2 rounded-md text-sm font-medium transition-colors ${
                activeTab === "grammar"
                  ? "bg-[#337fa1] text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              <CheckCircle className="w-4 h-4 inline-block mr-1" />
              Grammar Check
            </button>
            <button
              onClick={() => setActiveTab("examples")}
              className={`px-6 py-2 rounded-md text-sm font-medium transition-colors ${
                activeTab === "examples"
                  ? "bg-[#337fa1] text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              Practice Examples
            </button>
          </div>
        </div>

        {/* Language Toggle */}
        <div className="flex justify-center mb-4 py-0.5 ">
          <div className="flex bg-white rounded-lg p-1 shadow-sm border">
            <button
              onClick={() => setSelectedLang("english")}
              className={`px-2 py-1 rounded-md text-sm font-medium transition-colors ${
                selectedLang === "english"
                  ? "bg-[#337fa1] text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              English
            </button>
            <button
              onClick={() => setSelectedLang("amharic")}
              className={`px-2 py-1 rounded-md text-sm font-medium transition-colors ${
                selectedLang === "amharic"
                  ? "bg-[#337fa1] text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              አማርኛ (Amharic)
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Text Analysis */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader>
                <div className="flex items-start justify-between">
                  {/* Left: Text Analysis Title and Subtitle */}
                  <div>
                    <CardTitle className="flex items-center space-x-2 mb-1">
                      <span className="inline-block mr-2 align-middle">
                        <svg
                          width="22"
                          height="22"
                          viewBox="0 0 22 22"
                          fill="none"
                        >
                          <circle
                            cx="11"
                            cy="11"
                            r="10"
                            stroke="#112D4F"
                            strokeWidth="2"
                          />
                          <circle
                            cx="11"
                            cy="11"
                            r="6"
                            stroke="#112D4F"
                            strokeWidth="2"
                          />
                          <circle cx="11" cy="11" r="2" fill="#112D4F" />
                        </svg>
                      </span>
                      <span>Text Analysis</span>
                    </CardTitle>
                    <p className="text-sm text-[#476385]">
                      Paste your text below and I'll check for grammar,
                      spelling, and style issues
                    </p>
                  </div>
                  {/* Right: Mascot and Listen Carefully */}
                  <div className="flex flex-col items-center ml-4">
                    <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-lg">
                      <Image
                        src="/images/mascot.png"
                        alt="Grammar Coach Mascot"
                        width={128}
                        height={128}
                        className="w-32 h-32 rounded-[9999px] object-contain"
                      />
                    </div>
                    <div className="flex items-center text-xs text-black bg-[#D9E0ED] rounded-full mt-2 px-3 py-1 font-medium shadow">
                      🗣️ Just write
                    </div>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4 relative">
                <Textarea
                  placeholder={text || "hey There"}
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  className="min-h-[200px] resize-none pr-44"
                />
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-500">
                    {text.length} characters
                  </span>
                  <Button
                    onClick={handleAnalyze}
                    disabled={!text.trim() || isAnalyzing}
                    className="bg-[#337fa1] hover:bg-[#2c6e91]"
                  >
                    {isAnalyzing ? "Checking..." : "✓ Check Grammar"}
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Loading State */}
            {isAnalyzing && (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="animate-spin w-8 h-8 text-[#337fa1] mr-2" />
                <span className="text-[#337fa1] font-semibold text-lg">
                  Analyzing...
                </span>
              </div>
            )}

            {/* Error State */}
            {errorMsg && (
              <div className="bg-red-100 border border-red-300 text-red-700 rounded-lg p-4 mt-6 flex items-center gap-2">
                <AlertCircle className="w-5 h-5" />
                <span>{errorMsg}</span>
              </div>
            )}

            {/* Analysis Results */}
            {!isAnalyzing &&
              !errorMsg &&
              activeTab === "grammar" &&
              analysisResults && (
                <Card className="mt-6">
                  <CardHeader>
                    <CardTitle className="flex items-center space-x-2">
                      <span>Analysis Results</span>
                      <Badge
                        variant="secondary"
                        className="bg-blue-100 text-blue-800"
                      >
                        Score: {analysisResults.score} /100
                      </Badge>
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {/* Issues Block */}
                    {analysisResults.issuesFound > 0 && (
                      <div className="space-y-4 border rounded-xl p-4 bg-white">
                        <div className="flex items-center space-x-2 mb-2">
                          <AlertCircle className="w-5 h-5 text-yellow-500" />
                          <span className="font-semibold text-[#112D4F]">
                            {analysisResults.issuesFound} Issue
                            {analysisResults.issuesFound > 1 ? "s" : ""} Found
                          </span>
                        </div>
                        {analysisResults.issues.map(
                          (issue: any, index: number) => (
                            <div key={index} className="flex flex-col gap-2">
                              <div className="flex items-center gap-2">
                                <Badge
                                  variant="outline"
                                  className="text-xs bg-[#112D4F] text-white"
                                >
                                  grammar
                                </Badge>
                                <Badge
                                  variant="outline"
                                  className="text-xs bg-white text-[#112D4F]"
                                >
                                  medium priority
                                </Badge>
                                <Button
                                  className="text-xs bg-[#337fa1] ml-auto"
                                  onClick={() => handleApplyFix(issue)}
                                >
                                  Apply Fix
                                </Button>
                              </div>
                              <div className="text-sm flex items-center gap-2">
                                <span className="line-through text-red-600">
                                  "{issue.original}"
                                </span>
                                <span className="mx-2">→</span>
                                <span className="text-green-700">
                                  "{issue.suggestion}"
                                </span>
                              </div>
                              <p className="text-xs text-gray-900">
                                {typeof issue.message === "object"
                                  ? issue.message?.[selectedLang] ||
                                    issue.message?.english ||
                                    "No message"
                                  : issue.message}
                              </p>
                            </div>
                          )
                        )}
                      </div>
                    )}

                    {/* Perfect Grammar Block */}
                    {analysisResults.issuesFound === 0 && (
                      <div className="flex flex-col items-center py-6">
                        <div className="bg-green-100 rounded-full p-4 mb-2">
                          <CheckCircle className="w-10 h-10 text-green-500" />
                        </div>
                        <h3 className="text-xl font-semibold text-green-600 mb-1">
                          Perfect Grammar!
                        </h3>
                        <p className="text-green-700 text-sm">
                          No errors found in your text.
                        </p>
                      </div>
                    )}

                    {/* Improved Version Block */}
                    <div>
                      <div className="flex items-center space-x-2 mb-2">
                        <span className="text-green-600">⚡</span>
                        <span className="text-[#112D4F] font-semibold">
                          Improved Version
                        </span>
                      </div>
                      <div className="bg-blue-50 rounded-lg p-4 flex flex-col">
                        <p className="text-md text-[#112D4F] whitespace-pre-line mb-2">
                          {typeof analysisResults.improvedText === "object"
                            ? analysisResults.improvedText?.[selectedLang] ||
                              analysisResults.improvedText?.english ||
                              "No improved text"
                            : analysisResults.improvedText}
                        </p>
                        <div className="flex space-x-2 mt-2">
                          <Button
                            onClick={handleCopy}
                            className="text-xs bg-[#337fa1] text-black rounded flex items-center"
                          >
                            <Copy className="w-4 h-4 mr-1 text-white" />
                            Copy
                          </Button>
                          <Button
                            onClick={handleDownload}
                            className="text-xs bg-[#337fa1] text-black rounded flex items-center"
                          >
                            <Download className="w-4 h-4 mr-1 text-white" />
                            Download
                          </Button>
                        </div>
                      </div>
                    </div>

                    {/* Writing Tips Block */}
                    <div>
                      <div className="flex items-center space-x-2 mb-2">
                        <Lightbulb className="w-4 h-4 text-yellow-500" />
                        <span className="font-semibold text-[#112D4F]">
                          Writing Tips
                        </span>
                      </div>
                      <ul className="space-y-2">
                        {analysisResults.writingTips.map(
                          (tip: any, idx: number) => (
                            <li
                              key={idx}
                              className="flex items-center space-x-2 text-sm"
                            >
                              <Lightbulb className="w-3 h-3 text-yellow-500" />
                              <span className="text-[#112D4F]">
                                {typeof tip === "object"
                                  ? tip?.[selectedLang] ||
                                    tip?.english ||
                                    "No tip"
                                  : tip}
                              </span>
                            </li>
                          )
                        )}
                      </ul>
                    </div>
                  </CardContent>
                </Card>
              )}

            {/* Try Sample Texts - Only show in examples tab */}
            {activeTab === "examples" && (
              <Card className="mt-6">
                <CardHeader>
                  <CardTitle> Try Sample Texts</CardTitle>
                  <p className="text-sm text-gray-600">
                    Practice with these examples that contain common errors
                  </p>
                </CardHeader>
                <CardContent className="space-y-4">
                  {sampleTexts.map((sample) => (
                    <div
                      key={sample.id}
                      className="border rounded-lg p-4 bg-gray-50"
                    >
                      <p className="text-sm text-black mb-3">
                        {typeof sample.text === "object"
                          ? sample.text?.[selectedLang] ||
                            sample.text?.english ||
                            "No sample text"
                          : sample.text}
                      </p>
                      <Button
                        className="border bg-[#] text-[#112D4F]"
                        onClick={() => {
                          setText(
                            typeof sample.text === "object"
                              ? sample.text?.[selectedLang] ||
                                  sample.text?.english ||
                                  ""
                              : sample.text
                          );
                          setActiveTab("examples");
                          setAnalysisResults(null);
                        }}
                      >
                        {sample.title}
                      </Button>
                    </div>
                  ))}
                </CardContent>
              </Card>
            )}
          </div>

          {/* Right Column - Analysis Summary & Grammar Coach */}
          <div className="space-y-6">
            {/* Analysis Summary */}
            {analysisResults && (
              <Card>
                <CardHeader>
                  <CardTitle>Analysis Summary</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Grammar Score</span>
                    <Badge className="bg-blue-100 text-blue-800">
                      {analysisResults.score}/100
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Issues Found</span>
                    <span className="text-sm font-medium text-gray-900">
                      {analysisResults.issuesFound}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Word Count</span>
                    <span className="text-sm font-medium text-gray-900">
                      {analysisResults.wordCount}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Readability</span>
                    <Badge variant="outline" className="border-green-600">
                      <span className="text-green-600">Good</span>
                    </Badge>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Grammar Coach */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <span>✓ Your Grammar Coach</span>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="text-center">
                  <div className="flex flex-col items-center ml-4">
                    <div className="w-80 h-80 bg-white rounded-full flex items-center justify-center shadow-lg">
                      <div className="relative h-64 w-64 md:h-80 md:w-80 mx-auto flex items-center justify-center">
                        <img
                          src="/videos/sleepingmascot.gif"
                          alt="LissanAI Mascot Animation"
                          className="absolute inset-0 w-full h-full object-contain"
                        />
                      </div>
                    </div>
                    <div className="flex items-center text-xs text-black bg-[#D9E0ED] rounded-full mt-2 px-3 py-1 font-medium shadow">
                      🗣️ Write your text
                    </div>
                  </div>
                  <p className="text-sm text-gray-600 text-center">
                    I'm here to help you write with confidence! I find errors
                    and suggest improvements to make your writing shine.
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <h4 className="font-large text-black font-semibold">
                    Writing Tips
                  </h4>
                  <div className="space-y-2">
                    <div className="flex items-start space-x-2">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span className="text-sm text-black">
                        Read your text aloud to catch errors
                      </span>
                    </div>
                    <div className="flex items-start space-x-2">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span className="text-sm text-black">
                        Use active voice when possible
                      </span>
                    </div>
                    <div className="flex items-start space-x-2">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span className="text-sm text-black">
                        Keep sentences clear and concise
                      </span>
                    </div>
                    <div className="flex items-start space-x-2">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span className="text-sm text-black">
                        Check subject-verb agreement
                      </span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
