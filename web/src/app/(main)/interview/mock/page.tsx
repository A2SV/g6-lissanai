"use client";
import React, { useState, useRef as reactUseRef, useEffect } from "react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useSession } from "next-auth/react";

// Define a type for the feedback structure based on your API docs
// --- TYPE DEFINITIONS ---
interface Feedback {
  feedback_points: {
    focus_phrase: string;
    suggestion: string;
    type: string;
  }[];
  overall_summary: string;
  score_percentage: number;
  error?: string;
}

interface InterviewSummary {
  final_score: number;
  strengths: string[];
  weaknesses: string[];
  total_questions: number;
  completed: number;
}

// --- FULL PAGE LOADER (for initial setup) ---
const InterviewLoader: React.FC = () => (
  <div className="flex flex-col items-center justify-center min-h-[60vh]">
    <Image src="/images/mascot_img.png" alt="Mascot" width={120} height={120} />
    <h2 className="text-2xl font-bold mt-4 text-gray-800">
      Preparing Your Interview...
    </h2>
    <p className="text-gray-600 mt-2">Please wait a moment.</p>
    <div className="w-full max-w-sm mt-8 h-2 bg-gray-200 rounded-full overflow-hidden">
      <LineLoader /> {/* Using the new reusable loader */}
    </div>
  </div>
);

// --- NEW: REUSABLE ANIMATED LINE LOADER ---
// This component can be used anywhere a small loading indicator is needed.
const LineLoader: React.FC = () => (
  <>
    <style jsx>{`
      @keyframes loading-bar-animation {
        0% {
          transform: translateX(-100%);
        }
        100% {
          transform: translateX(250%);
        }
      }
      .animate-loading-bar {
        animation: loading-bar-animation 1.5s infinite linear;
      }
    `}</style>
    <div className="w-1/3 h-full bg-blue-500 rounded-full animate-loading-bar"></div>
  </>
);
// ------------------ HEADER ------------------
const Header: React.FC = () => {
  return (
    <header className="w-full bg-white shadow-sm px-8 py-3 flex items-center justify-between">
      <Image src="/images/logo.png" alt="Mascot" width={130} height={130} />
      <nav className="flex space-x-6 text-gray-600 font-medium">
        <a href="#" className="hover:text-blue-500">
          Mock Interviews
        </a>
        <a href="#" className="hover:text-blue-500">
          Grammar Coach
        </a>
        <a href="#" className="hover:text-blue-500">
          Learn
        </a>
        <a href="#" className="hover:text-blue-500">
          Email Drafting
        </a>
        <a href="#" className="hover:text-blue-500">
          Pronunciation
        </a>
      </nav>
    </header>
  );
};

// --- NEW: INTERVIEW SUMMARY COMPONENT ---
// --- CORRECTED: INTERVIEW SUMMARY COMPONENT ---
const InterviewSummaryCard: React.FC<{
  summary: InterviewSummary;
  onRestart: () => void;
}> = ({ summary, onRestart }) => {
  // We use the Nullish Coalescing Operator (??) to provide a fallback empty array.
  // This ensures that if the API sends `null`, we use `[]` instead, preventing the crash.
  const strengths = summary.strengths ?? [];
  const weaknesses = summary.weaknesses ?? [];

  return (
    <div className="flex flex-col items-center p-6 w-full">
      <Image
        src="/images/mascot_img.png"
        alt="Mascot"
        width={120}
        height={120}
        className="mt-6"
      />
      <h2 className="text-4xl font-bold mt-4 text-black">
        🎉 Interview Complete! 🎉
      </h2>
      <p className="text-gray-600 mt-2">Here's your summary:</p>

      <div className="bg-white shadow-xl rounded-2xl p-8 mt-8 w-full max-w-2xl">
        <div className="text-center mb-6">
          <p className="text-gray-600 font-semibold">Your Final Score</p>
          <p className="text-6xl font-bold text-blue-600">
            {summary.final_score}%
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Strengths Section */}
          <div>
            <h3 className="text-lg font-semibold text-green-700 flex items-center mb-3">
              <span className="text-2xl mr-2">👍</span> Strengths
            </h3>
            <ul className="list-disc pl-5 space-y-2 text-gray-700">
              {strengths.length > 0 ? (
                strengths.map((point, index) => (
                  <li key={`str-${index}`}>{point}</li>
                ))
              ) : (
                <li>No specific strengths identified in this session.</li>
              )}
            </ul>
          </div>

          {/* Weaknesses Section */}
          <div>
            <h3 className="text-lg font-semibold text-yellow-700 flex items-center mb-3">
              <span className="text-2xl mr-2">💡</span> Areas for Improvement
            </h3>
            <ul className="list-disc pl-5 space-y-2 text-gray-700">
              {weaknesses.length > 0 ? (
                weaknesses.map((point, index) => (
                  <li key={`weak-${index}`}>{point}</li>
                ))
              ) : (
                <li>
                  No specific areas for improvement identified. Great job!
                </li>
              )}
            </ul>
          </div>
        </div>
      </div>

      <button
        onClick={onRestart}
        className="mt-10 px-8 py-3 bg-blue-600 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 transition-transform transform hover:scale-105"
      >
        Practice Again
      </button>
    </div>
  );
};

// ------------------ MAIN PAGE ------------------
const MockInterview: React.FC = () => {
  const [step, setStep] = useState(1);
  const [recordingStage, setRecordingStage] = useState<
    "idle" | "recording" | "completed"
  >("idle");

  // UPDATED: Added 'completed' state
  const [interviewState, setInterviewState] = useState<
    "loading" | "ready" | "completed" | "error"
  >("loading");
  const [interviewSummary, setInterviewSummary] =
    useState<InterviewSummary | null>(null);

  const { data: session } = useSession();
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [question, setQuestion] = useState<string>("");
  const [isNewQuestionLoading, setIsNewQuestionLoading] = useState(true);
  const base = process.env.NEXT_PUBLIC_API_BASE_URL!;

  const fetchNextQuestion = async (sid: string) => {
    if (!session?.accessToken) return;
    setIsNewQuestionLoading(true); // Start loading animation
    try {
      const res = await fetch(
        `${base}/interview/question?session_id=${encodeURIComponent(sid)}`,
        {
          headers: {
            accept: "application/json",
            Authorization: `Bearer ${session.accessToken}`,
          },
        }
      );
      if (!res.ok) throw new Error("Failed to fetch question");
      const data = await res.json();
      setQuestion(
        data.question || "Failed to load question. Please try again."
      );
    } catch (error) {
      console.error("Fetch question error:", error);
      setQuestion("Error: Could not load the next question.");
    } finally {
      setIsNewQuestionLoading(false); // Stop loading animation
    }
  };

  const startInterview = async () => {
    if (!session?.accessToken) return;
    try {
      const res = await fetch(`${base}/interview/start`, {
        method: "POST",
        headers: {
          accept: "application/json",
          Authorization: `Bearer ${session.accessToken}`,
        },
      });
      if (!res.ok) throw new Error("Failed to start session");
      const data = await res.json();
      setSessionId(data.session_id);
      await fetchNextQuestion(data.session_id);
      setInterviewState("ready");
    } catch (error) {
      console.error("Start interview error:", error);
      setInterviewState("error");
    }
  };

  // NEW: Function to end the interview and fetch the summary
  const completeInterview = async () => {
    if (!session?.accessToken || !sessionId) return;
    try {
      const res = await fetch(
        `${base}/interview/${encodeURIComponent(sessionId)}/end`,
        {
          method: "POST",
          headers: { Authorization: `Bearer ${session.accessToken}` },
        }
      );
      if (!res.ok) throw new Error("Failed to fetch summary");
      const summaryData: InterviewSummary = await res.json();
      setInterviewSummary(summaryData);
      setInterviewState("completed"); // Transition to the summary view
    } catch (error) {
      console.error("Failed to end interview:", error);
      // Fallback in case the summary API fails
      alert(
        "Interview finished, but we couldn't load your summary. Please try again later."
      );
      setInterviewState("error");
    }
  };
  useEffect(() => {
    if (session?.accessToken && interviewState === "loading") {
      startInterview();
    }
  }, [session?.accessToken, interviewState]);

  const handleNext = () => {
    if (step < 5) {
      setStep(step + 1);
      setRecordingStage("idle");
      if (sessionId) fetchNextQuestion(sessionId);
    } else {
      // Instead of alert, call the function to get the summary
      completeInterview();
    }
  };

  const handlePrev = () => {
    if (step > 1) setStep(step - 1);
  };

  if (interviewState === "loading") {
    return <InterviewLoader />;
  }

  if (interviewState === "error") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <h2 className="text-2xl font-bold text-red-600">
          ❌ An Error Occurred
        </h2>
        <p className="mt-2 text-gray-600">
          Could not start the interview session. Please try again later.
        </p>
        <button
          onClick={() => window.location.reload()}
          className="mt-6 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
        >
          Try Again
        </button>
      </div>
    );
  }

  if (interviewState === "completed" && interviewSummary) {
    return (
      <InterviewSummaryCard
        summary={interviewSummary}
        onRestart={() => window.location.reload()}
      />
    );
  }

  return (
    <div className="flex flex-col items-center p-6">
      <Image
        src="/images/mascot_img.png"
        alt="Mascot"
        width={120}
        height={120}
        className="mt-6"
      />
      <h2 className="text-4xl font-bold mt-4 text-black">
        🎯 Mock Interview Practice
      </h2>
      <MessageBox step={step} total={5} />
      <ModeToggle />
      <ProgressBar step={step} total={5} />
      <QuestionCard
        question={question}
        tip="Keep it professional, focus on relevant experience, and be concise."
        isLoading={isNewQuestionLoading}
      />
      <RecordSection
        key={step}
        recordingStage={recordingStage}
        setRecordingStage={setRecordingStage}
        sessionId={sessionId || undefined}
        accessToken={session?.accessToken}
      />
      <FooterControls onPrev={handlePrev} onNext={handleNext} />
    </div>
  );
};
// ------------------ MESSAGE BOX ------------------
interface MessageBoxProps {
  step: number;
  total: number;
}
const MessageBox: React.FC<MessageBoxProps> = ({ step, total }) => (
  <div className="flex items-center mt-4 space-x-6 w-full max-w-5xl mx-auto">
    <Image src="/images/mascot_img.png" alt="Mascot" width={56} height={56} />
    <div
      className="rounded-xl py-3 px-6 shadow flex-1"
      style={{ backgroundColor: "#DDFFEF", border: "2px solid #A7F3D0" }}
    >
      <p className="text-gray-700 font-medium text-center">
        Question {step} of {total}. Let’s practice this together! 💪
      </p>
    </div>
  </div>
);

// ------------------ MODE TOGGLE ------------------
const ModeToggle: React.FC = () => {
  const router = useRouter();
  const [mode, setMode] = useState<"interview" | "free">("interview");

  const handleModeChange = (newMode: "interview" | "free") => {
    setMode(newMode);
    if (newMode === "free") router.push("./free_speaking");
    else router.push("/mock");
  };

  return (
    <div className="flex mt-6 px-0.5 py-0.5 rounded-lg border-2 border-gray-300">
      <button
        className={`flex items-center px-10 py-2 rounded-lg font-medium transition-all duration-300 ${
          mode === "interview"
            ? "bg-[#39647E] text-white border-2 border-[#39647E]"
            : "bg-gray-100 text-gray-600 border-0"
        }`}
        onClick={() => handleModeChange("interview")}
      >
        <div className="w-6 h-6 mr-2">
          <Image
            src={
              mode === "interview"
                ? "/images/interview_active.png"
                : "/images/interview_inactive.png"
            }
            alt="Mock Interview"
            width={24}
            height={24}
          />
        </div>
        Mock Interview
      </button>

      <button
        className={`flex items-center px-10 py-2 rounded-lg font-medium transition-all duration-300 ${
          mode === "free"
            ? "bg-[#39647E] text-white border-2 border-[#39647E]"
            : "bg-gray-100 text-gray-600 border-0"
        }`}
        onClick={() => handleModeChange("free")}
      >
        <div className="w-6 h-6 mr-2">
          <Image
            src={
              mode === "free"
                ? "/images/voice_active.png"
                : "/images/voice_inactive.png"
            }
            alt="Free Speaking"
            width={24}
            height={24}
          />
        </div>
        Free Speaking
      </button>
    </div>
  );
};

// ------------------ PROGRESS BAR ------------------
interface ProgressBarProps {
  step: number;
  total: number;
}
const ProgressBar: React.FC<ProgressBarProps> = ({ step, total }) => (
  <div className="flex items-center mt-4 w-full max-w-xl">
    <div className="flex-1 bg-gray-200 rounded-full h-2 relative">
      <div
        className="bg-green-500 h-2 rounded-full transition-all duration-500"
        style={{ width: `${(step / total) * 100}%` }}
      ></div>
    </div>
    <span className="ml-3 text-gray-700 font-medium">
      {step}/{total}
    </span>
  </div>
);

// ------------------ QUESTION CARD ------------------

interface QuestionCardProps {
  question: string;
  tip: string;
  // This prop is for the loading animation, let's keep it for consistency
  isLoading: boolean;
}

const QuestionCard: React.FC<QuestionCardProps> = ({
  question,
  tip,
  isLoading,
}) => {
  const [isSpeaking, setIsSpeaking] = useState(false);

  // Function to handle the text-to-speech functionality
  const handleSpeak = () => {
    // Check if the Speech Synthesis API is supported by the browser
    if (!("speechSynthesis" in window)) {
      alert("Sorry, your browser doesn't support text-to-speech.");
      return;
    }

    // If speech is currently happening, cancel it. This makes the button a toggle.
    if (speechSynthesis.speaking) {
      speechSynthesis.cancel();
      setIsSpeaking(false); // Manually update state as onend doesn't fire for cancel
      return;
    }

    // Create a new speech utterance with the question text
    const utterance = new SpeechSynthesisUtterance(question);

    // Set listeners to update the UI state
    utterance.onstart = () => setIsSpeaking(true);
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);

    // Speak the text
    window.speechSynthesis.speak(utterance);
  };

  // This effect ensures that if the component unmounts (e.g., user clicks "Next Question"),
  // any ongoing speech is stopped.
  useEffect(() => {
    return () => {
      if (speechSynthesis.speaking) {
        speechSynthesis.cancel();
      }
    };
  }, []); // The empty array ensures this only runs on mount and unmount

  return (
    <div className="bg-white shadow-md rounded-2xl p-6 mt-6 w-full max-w-5xl mx-auto ">
      <div className="flex justify-between items-center mb-4">
        <div className="flex space-x-2">
          <span className="px-3 py-1 text-xs rounded-full bg-blue-100 text-blue-600 font-medium">
            General
          </span>
          <span className="px-3 py-1 text-xs rounded-full bg-green-100 text-green-600 font-medium">
            Easy
          </span>
          <span className="px-3 py-1 text-xs rounded-full bg-yellow-100 text-yellow-600 font-medium">
            ⭐ 50XP
          </span>
        </div>

        {/* --- UPDATED BUTTON --- */}
        <button
          onClick={handleSpeak}
          className="flex items-center px-4 py-2 bg-blue-50 text-blue-500 rounded-full text-sm font-medium hover:bg-blue-100 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          // Disable the button if loading or if there's no valid question
          disabled={isLoading || !question || question.startsWith("Error:")}
        >
          {/* The speaker icon and text now change based on the 'isSpeaking' state */}
          <span className="mr-2 text-lg">{isSpeaking ? "⏹️" : "🔊"}</span>
          {isSpeaking ? "Stop" : "Listen"}
        </button>
      </div>

      {/* This div ensures the card height doesn't change during loading */}
      <div className="min-h-[50px] flex flex-col justify-center">
        {isLoading ? (
          <div className="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
            <LineLoader />
          </div>
        ) : (
          <p className="text-gray-800 font-medium text-lg">{question}</p>
        )}
      </div>

      <div className="flex items-start space-x-2 mt-4 bg-blue-50 p-3 rounded-lg text-sm text-gray-700">
        <span className="text-green-600 text-lg">🎯</span>
        <div>
          <p className="font-semibold text-green-600">Lissan’s Tip:</p>
          <p>{tip}</p>
        </div>
      </div>
    </div>
  );
};

// ------------------ RECORD SECTION (UPDATED) ------------------
interface RecordSectionProps {
  recordingStage: "idle" | "recording" | "completed";
  setRecordingStage: React.Dispatch<
    React.SetStateAction<"idle" | "recording" | "completed">
  >;
  sessionId?: string;
  accessToken?: string;
}

const RecordSection: React.FC<RecordSectionProps> = ({
  recordingStage,
  setRecordingStage,
  sessionId,
  accessToken,
}) => {
  const [transcript, setTranscript] = useState<string>("");
  const [isTranscribing, setIsTranscribing] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false); // For feedback loading
  const [feedback, setFeedback] = useState<Feedback | null>(null);

  const mediaRecorderRef = reactUseRef<MediaRecorder | null>(null);
  const chunks = reactUseRef<Blob[]>([]);
  const streamRef = reactUseRef<MediaStream | null>(null);

  // This function is now triggered by the "Get AI Feedback" button
  const handleGetFeedback = async () => {
    if (!transcript?.trim() || !accessToken || !sessionId) {
      console.error("Cannot get feedback: Missing transcript or session info.");
      return;
    }

    setIsSubmitting(true);
    setFeedback(null); // Clear old feedback

    const base = process.env.NEXT_PUBLIC_API_BASE_URL;
    if (!base) {
      console.error("Missing NEXT_PUBLIC_API_BASE_URL");
      setIsSubmitting(false);
      return;
    }

    try {
      const res = await fetch(`${base}/interview/answer`, {
        method: "POST",
        headers: {
          accept: "application/json",
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ answer: transcript, session_id: sessionId }),
      });

      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || "Failed to submit answer");
      }

      const feedbackData: Feedback = await res.json();
      setFeedback(feedbackData);
    } catch (e: unknown) {
      console.error("Submit answer error:", e);
      setFeedback({
        feedback_points: [],
        overall_summary: "",
        score_percentage: 0,
        error: "Sorry, an error occurred while generating feedback.",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  // Send audio to backend for transcription
  const transcribeAudio = async (audioBlob: Blob) => {
    const formData = new FormData();
    formData.append("file", audioBlob, "recording.webm");

    try {
      setIsTranscribing(true);
      const response = await fetch("/api/interview", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || "Failed to transcribe audio");
      }

      const data = await response.json();
      const text = data.text || "⚠️ Could not transcribe. Please try again.";
      setTranscript(text);

      // --- CHANGE ---
      // The feedback call is no longer automatic. It waits for the user to click the button.
    } catch (error: unknown) {
      console.error("Transcription error:", error);
      setTranscript("⚠️ Error transcribing audio. Please try again.");
    } finally {
      setIsTranscribing(false);
    }
  };

  // Start Recording (clears old feedback and transcript)
  const startRecording = async () => {
    setFeedback(null);
    setTranscript("");
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          /* ... */
        },
      });
      streamRef.current = stream;
      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: "audio/webm;codecs=opus",
      });
      mediaRecorderRef.current = mediaRecorder;
      chunks.current = [];
      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunks.current.push(e.data);
      };
      mediaRecorder.onstop = () => {
        const blob = new Blob(chunks.current, { type: "audio/webm" });
        chunks.current = [];
        transcribeAudio(blob);
        if (streamRef.current) {
          streamRef.current.getTracks().forEach((track) => track.stop());
          streamRef.current = null;
        }
      };
      mediaRecorder.start();
      setRecordingStage("recording");
    } catch (err) {
      console.error("Microphone access denied:", err);
      setTranscript("⚠️ Please allow microphone access to record.");
    }
  };

  // Stop Recording
  const stopRecording = () => {
    if (
      mediaRecorderRef.current &&
      mediaRecorderRef.current.state !== "inactive"
    ) {
      mediaRecorderRef.current.stop();
      setRecordingStage("completed");
    }
  };

  // Reset to Idle
  const resetRecording = () => {
    setRecordingStage("idle");
    setTranscript("");
    setFeedback(null);
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
  };

  return (
    <>
      {/* Idle Stage */}
      {recordingStage === "idle" && (
        <div
          className="flex flex-col items-center mt-10 rounded-2xl p-8 w-full max-w-5xl"
          style={{ boxShadow: "0 0 15px rgba(78, 195, 253, 0.8)" }}
        >
          <button
            className="w-32 h-32 rounded-full flex items-center justify-center hover:scale-105 transition"
            onClick={startRecording}
          >
            <Image
              src="/images/record1.png"
              alt="Start Recording"
              width={140}
              height={140}
            />
          </button>
          <p className="mt-4 text-gray-600 text-sm">
            Ready to record your answer?
          </p>
        </div>
      )}

      {/* Recording Stage */}
      {recordingStage === "recording" && (
        <div
          className="flex flex-col items-center mt-10 rounded-2xl p-8 w-full max-w-5xl"
          style={{ boxShadow: "0 0 15px #FF9196" }}
        >
          <button
            className="w-32 h-32 rounded-full flex items-center justify-center hover:scale-105 transition"
            onClick={stopRecording}
          >
            <Image
              src="/images/record2.png"
              alt="Recording"
              width={140}
              height={140}
            />
          </button>
          <h2 className="mt-6 text-xl font-bold text-gray-800">
            🎤 Recording in progress...
          </h2>
        </div>
      )}

      {/* Completed Stage */}
      {recordingStage === "completed" && (
        <div
          className="flex flex-col items-center mt-10 rounded-2xl p-8 w-full max-w-5xl"
          style={{ boxShadow: "0 0 15px #c8c8c8" }}
        >
          <div className="text-green-600 font-semibold text-lg mb-6">
            ✅ Recording completed!
          </div>

          <div className="w-full bg-white border rounded-xl p-6 shadow">
            <h3 className="text-gray-800 font-semibold mb-2">
              📝 Your Transcript:
            </h3>
            {isTranscribing ? (
              <p className="text-gray-600 italic">Transcribing your audio...</p>
            ) : (
              <p className="text-gray-700 whitespace-pre-wrap">{transcript}</p>
            )}
          </div>

          {/* Feedback Display Section */}
          {feedback && (
            <div className="mt-6 w-full bg-blue-50 border border-blue-200 rounded-xl p-6 shadow">
              <h3 className="text-blue-800 font-semibold mb-2">
                ⚡ AI Feedback:
              </h3>
              {isSubmitting ? (
                <p className="text-gray-600 italic">Generating feedback...</p>
              ) : (
                <div className="text-black">
                  <p className="font-semibold">Overall Summary:</p>
                  <p className="mb-4 text-black">{feedback.overall_summary}</p>
                  <p className="font-semibold">Score:</p>
                  <p className="mb-4 text-green-600 font-bold">
                    {feedback.score_percentage}%
                  </p>
                  <p className="font-semibold">Suggestions:</p>
                  <ul className="list-disc pl-5 mt-2">
                    {feedback.feedback_points?.map((point, index) => (
                      <li key={index} className="mb-2 text-black">
                        <strong>{point.focus_phrase}:</strong>{" "}
                        {point.suggestion}
                        <span className="text-xs ml-2 px-2 py-0.5 bg-gray-200 rounded-full">
                          {point.type}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex items-center justify-center mt-6 space-x-4">
            <button
              className="px-6 py-2 rounded-xl bg-purple-100 text-purple-700 font-medium hover:bg-purple-200 transition"
              onClick={resetRecording}
            >
              ⟳ Try Again
            </button>
            <button
              className="px-6 py-2 rounded-xl bg-green-500 text-white font-medium hover:bg-green-600 transition disabled:bg-gray-400"
              onClick={handleGetFeedback}
              // Disable button while transcribing, submitting, or if transcript is invalid
              disabled={
                isTranscribing || isSubmitting || transcript.startsWith("⚠️")
              }
            >
              {isSubmitting ? "Generating..." : "⚡ Get AI Feedback (+50 XP)"}
            </button>
          </div>
        </div>
      )}
    </>
  );
};

// ------------------ FOOTER CONTROLS ------------------
interface FooterControlsProps {
  onPrev: () => void;
  onNext: () => void;
}
const FooterControls: React.FC<FooterControlsProps> = ({ onPrev, onNext }) => (
  <div className="flex items-center justify-between mt-12 w-full max-w-2xl mx-auto">
    <button
      onClick={onPrev}
      className="px-4 py-2 rounded-lg text-gray-600 font-medium transition-all duration-200 hover:bg-blue-50 hover:text-blue-600 active:scale-95"
      style={{ border: "2px solid #4EC3FD" }}
    >
      <span className="font-bold text-lg leading-none mr-1">←</span>Previous
    </button>
    <p className="text-orange-500 text-sm">
      🔥 Keep practicing to maintain your streak!
    </p>
    <button
      onClick={onNext}
      className="px-5 py-2 text-white rounded-lg shadow transition-all duration-200 hover:opacity-90 active:scale-95 flex items-center justify-center space-x-2"
      style={{ backgroundColor: "#39647E" }}
    >
      <span>Next Question</span>
      <span className="font-bold text-lg leading-none mr-1">→</span>
    </button>
  </div>
);

// ------------------ APP ROOT ------------------
const App: React.FC = () => (
  <div className="min-h-screen bg-gray-50">
    <Header />
    <MockInterview />
  </div>
);

export default App;
