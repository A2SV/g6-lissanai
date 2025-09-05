"use client";
import React, { useState, useRef, useEffect } from "react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import VoiceCircle from "./VoiceCircle";
import TypingIndicator from "./TypingIndicator";
import RespondingBars from "./RespondingBars";

// Define the conversation states
type ConversationState = "idle" | "recording" | "processing" | "responding";

// --- Configuration Constants ---
const SILENCE_THRESHOLD = 0.025;
const SILENCE_DURATION_MS = 1500;
const CONVERSATION_TIMEOUT_MS = 180000; // 3 minutes

// ------------------ HEADER COMPONENT ------------------
const Header: React.FC = () => (
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

// ------------------ MAIN PAGE COMPONENT ------------------
const FreeSpeaking: React.FC = () => {
  const router = useRouter();
  const [conversationState, setConversationState] =
    useState<ConversationState>("idle");
  const [userVolume, setUserVolume] = useState(0);

  const socketRef = useRef<WebSocket | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const userAudioContextRef = useRef<AudioContext | null>(null);
  const userAnalyserRef = useRef<AnalyserNode | null>(null);
  const silenceTimerRef = useRef<NodeJS.Timeout | null>(null);
  const animationFrameRef = useRef<number | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const conversationTimerRef = useRef<NodeJS.Timeout | null>(null);

  const monitorMicrophone = () => {
    if (!userAnalyserRef.current) return;

    // Cancel any previous animation frame before starting a new one.
    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current);
    }

    const analyser = userAnalyserRef.current;
    const dataArray = new Uint8Array(analyser.frequencyBinCount);
    const animationLoop = () => {
      if (mediaRecorderRef.current?.state !== "recording") {
        if (animationFrameRef.current)
          cancelAnimationFrame(animationFrameRef.current);
        return;
      }
      analyser.getByteTimeDomainData(dataArray);
      let sum = 0;
      for (const value of dataArray) {
        const normalizedValue = (value - 128) / 128;
        sum += normalizedValue * normalizedValue;
      }
      const rms = Math.sqrt(sum / dataArray.length);
      setUserVolume(rms);
      if (rms < SILENCE_THRESHOLD) {
        if (!silenceTimerRef.current) {
          silenceTimerRef.current = setTimeout(
            stopUserRecording,
            SILENCE_DURATION_MS
          );
        }
      } else {
        if (silenceTimerRef.current) clearTimeout(silenceTimerRef.current);
        silenceTimerRef.current = null;
      }
      animationFrameRef.current = requestAnimationFrame(animationLoop);
    };
    animationLoop();
  };

  const beginRecordingTurn = () => {
    // CRITICAL FIX: Resume the AudioContext in case the browser suspended it.
    if (
      userAudioContextRef.current &&
      userAudioContextRef.current.state === "suspended"
    ) {
      userAudioContextRef.current.resume();
    }

    if (!mediaRecorderRef.current) return;

    // Only start the recorder if it's not already recording.
    if (mediaRecorderRef.current.state === "inactive") {
      mediaRecorderRef.current.start(500); // Start sending data in chunks
    }

    setConversationState("recording");
    monitorMicrophone();
  };

  const stopUserRecording = () => {
    if (animationFrameRef.current)
      cancelAnimationFrame(animationFrameRef.current);
    if (silenceTimerRef.current) clearTimeout(silenceTimerRef.current);
    setUserVolume(0);

    if (mediaRecorderRef.current?.state === "recording") {
      // Just stop the recorder. The 'onstop' event will handle the rest.
      mediaRecorderRef.current.stop();
    }
  };

  const startConversation = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;

      type WindowWithWebkit = Window & {
        webkitAudioContext?: { new (): AudioContext };
      };

      const AudioContextCtor: { new (): AudioContext } | undefined =
        typeof window !== "undefined"
          ? typeof AudioContext !== "undefined"
            ? AudioContext
            : (window as WindowWithWebkit).webkitAudioContext
          : undefined;

      if (!AudioContextCtor) {
        alert("Browser does not support the Web Audio API.");
        return;
      }

      userAudioContextRef.current = new AudioContextCtor();
      const ctx = userAudioContextRef.current!;
      const source = ctx.createMediaStreamSource(stream);
      userAnalyserRef.current = ctx.createAnalyser();
      userAnalyserRef.current.fftSize = 2048;
      source.connect(userAnalyserRef.current);

      mediaRecorderRef.current = new MediaRecorder(stream, {
        mimeType: "audio/webm",
      });

      mediaRecorderRef.current.ondataavailable = (event) => {
        if (
          event.data.size > 0 &&
          socketRef.current?.readyState === WebSocket.OPEN
        ) {
          socketRef.current.send(event.data);
        }
      };

      // CRITICAL FIX: Use the 'onstop' event for safer state management.
      mediaRecorderRef.current.onstop = () => {
        if (socketRef.current?.readyState === WebSocket.OPEN) {
          socketRef.current.send(JSON.stringify({ type: "end_of_speech" }));
          setConversationState("processing");
        }
      };

      if (conversationTimerRef.current)
        clearTimeout(conversationTimerRef.current);
      conversationTimerRef.current = setTimeout(
        cleanUp,
        CONVERSATION_TIMEOUT_MS
      );

      const wsUrl =
        process.env.NEXT_PUBLIC_WS_BASE_URL ||
        "https://lissan-ai-backend-dev.onrender.com/api/v1/ws/conversation";
      const socket = new WebSocket(wsUrl);
      socketRef.current = socket;

      socket.onopen = () => beginRecordingTurn();

      socket.onmessage = (event) => {
        if (typeof event.data === "string") {
          const message = JSON.parse(event.data);
          if (message.status === "processing")
            setConversationState("processing");
        } else if (event.data instanceof Blob) {
          const audioUrl = URL.createObjectURL(event.data);
          const newAiAudio = new Audio(audioUrl);
          setConversationState("responding");
          newAiAudio.play();
          newAiAudio.onended = () => {
            // Check if the session is still active before starting the next turn
            if (conversationTimerRef.current) {
              beginRecordingTurn();
            }
          };
        }
      };
      socket.onclose = () => cleanUp();
      socket.onerror = (error) => {
        console.error("WebSocket error:", error);
        cleanUp();
      };
    } catch (err) {
      console.error("Microphone access denied:", err);
      alert("Microphone access is required for this feature.");
    }
  };

  const cleanUp = () => {
    if (conversationTimerRef.current) {
      clearTimeout(conversationTimerRef.current);
      conversationTimerRef.current = null;
    }
    if (animationFrameRef.current)
      cancelAnimationFrame(animationFrameRef.current);
    if (silenceTimerRef.current) clearTimeout(silenceTimerRef.current);

    if (mediaRecorderRef.current?.state === "recording") {
      mediaRecorderRef.current.stop();
    }

    streamRef.current?.getTracks().forEach((track) => track.stop());
    streamRef.current = null;

    socketRef.current?.close();

    userAudioContextRef.current
      ?.close()
      .then(() => (userAudioContextRef.current = null));

    setConversationState("idle");
    setUserVolume(0);
  };

  useEffect(() => {
    return () => cleanUp();
  }, []);

  const handleCircleClick = () => {
    if (conversationState === "idle") startConversation();
    else if (conversationState === "recording") stopUserRecording();
  };

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
        🎤 Free Speaking Practice
      </h2>
      <MessageBox />
      <ModeToggle />
      <div
        className="flex flex-col items-center mt-10 rounded-2xl p-8 w-full max-w-xl transition-shadow duration-500"
        style={{
          boxShadow:
            conversationState === "recording"
              ? "0 0 25px #FF9196"
              : conversationState === "idle"
              ? "0 0 25px rgba(78, 195, 253, 0.8)"
              : "0 0 15px #c8c8c8",
        }}
      >
        {conversationState === "processing" ? (
          <TypingIndicator />
        ) : conversationState === "responding" ? (
          <div className="flex items-center justify-center h-[160px] w-[160px]">
            <RespondingBars />
          </div>
        ) : (
          <VoiceCircle
            state={conversationState as "idle" | "recording"}
            onClick={handleCircleClick}
            userVolume={userVolume}
          />
        )}

        {conversationState === "idle" && (
          <p className="mt-4 text-gray-600 text-sm">
            Click to start your 3-minute session
          </p>
        )}
        {conversationState === "recording" && (
          <>
            <h2 className="mt-6 text-xl font-bold text-gray-800">
              Listening...
            </h2>
            <p className="mt-2 text-gray-600 text-base">
              Stop talking to send, or click the circle.
            </p>
          </>
        )}
        {conversationState === "processing" && (
          <p className="mt-4 text-gray-600 text-base italic">
            Lissan is thinking...
          </p>
        )}
        {conversationState === "responding" && (
          <p className="mt-4 text-gray-600 text-base">
            Lissan is responding...
          </p>
        )}

        {conversationState !== "idle" && (
          <button
            className="mt-6 px-6 py-2 rounded-xl bg-red-500 text-white font-medium hover:bg-red-600 transition"
            onClick={cleanUp}
          >
            End Session
          </button>
        )}
      </div>
      <FooterControls />
    </div>
  );
};

// ------------------ OTHER UI COMPONENTS (Full Code) ------------------
const MessageBox: React.FC = () => (
  <div className="flex items-center mt-4 space-x-6 w-full max-w-5xl mx-auto">
    <Image src="/images/mascot_img.png" alt="Mascot" width={56} height={56} />
    <div
      className="rounded-xl py-3 px-6 shadow flex-1"
      style={{ backgroundColor: "#DDFFEF", border: "2px solid #A7F3D0" }}
    >
      <p className="text-gray-700 font-medium text-center">
        Let&apos;s practice speaking! Click the microphone to start.
      </p>
    </div>
  </div>
);

const ModeToggle: React.FC = () => {
  const router = useRouter();
  const [mode, setMode] = useState<"interview" | "free">("free");
  const handleModeChange = (newMode: "interview" | "free") => {
    setMode(newMode);
    if (newMode === "interview") router.push("./mock");
    else router.push("/free_speaking");
  };
  return (
    <div className="flex mt-6 px-0.5 py-0.5 rounded-lg border-2 border-gray-300">
      <button
        className={`flex items-center px-10 py-2 rounded-lg font-medium transition-all duration-300 ${
          mode === "interview"
            ? "bg-[#39647E] text-white"
            : "bg-gray-100 text-gray-600"
        }`}
        onClick={() => handleModeChange("interview")}
      >
        <Image
          src={
            mode === "interview"
              ? "/images/interview_active.png"
              : "/images/interview_inactive.png"
          }
          alt="Mock Interview"
          width={24}
          height={24}
          className="mr-2"
        />
        Mock Interview
      </button>
      <button
        className={`flex items-center px-10 py-2 rounded-lg font-medium transition-all duration-300 ${
          mode === "free"
            ? "bg-[#39647E] text-white"
            : "bg-gray-100 text-gray-600"
        }`}
        onClick={() => handleModeChange("free")}
      >
        <Image
          src={
            mode === "free"
              ? "/images/voice_active.png"
              : "/images/voice_inactive.png"
          }
          alt="Free Speaking"
          width={24}
          height={24}
          className="mr-2"
        />
        Free Speaking
      </button>
    </div>
  );
};

const FooterControls: React.FC = () => (
  <div className="flex items-center justify-center mt-12 w-full max-w-2xl mx-auto">
    <p className="text-orange-500 text-sm text-center">
      🔥 Keep practicing to maintain your streak!
    </p>
  </div>
);

const App: React.FC = () => (
  <div className="min-h-screen bg-gray-50">
    <Header />
    <FreeSpeaking />
  </div>
);

export default App;
