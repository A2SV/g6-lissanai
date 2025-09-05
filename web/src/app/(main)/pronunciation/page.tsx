"use client";

import { useState, useEffect, useRef } from "react";
import Header from "@/components/Header"
import Image from "next/image"
import { FaHeadphones, FaMicrophone, FaPlay } from "react-icons/fa"
import { FiRefreshCw, FiSquare, FiCheckCircle } from "react-icons/fi";
import toast, { Toaster } from "react-hot-toast";

/* eslint-disable @typescript-eslint/no-explicit-any */

interface PracticeSentence {
  id: string;
  text: string;
}
interface AssessmentFeedback {
  full_feedback_summary: string;
  mispronouncedwords: string[];
  overall_accuracy_score: number;
}
type RecordingStatus = "idle" | "recording" | "processing" | "completed";

const HighlightedSentence = ({ sentence, mispronouncedWords }: { sentence: string, mispronouncedWords: string[] }) => {
  const mispronouncedSet = new Set(mispronouncedWords.map(word => word.toLowerCase().replace(/[.,!?]/g, '')));
  const words = sentence.split(/(\s+)/);
  return (
    <p className="text-3xl font-bold leading-relaxed">
      {words.map((word, index) => {
        const normalizedWord = word.toLowerCase().replace(/[.,!?]/g, '');
        const isMispronounced = mispronouncedSet.has(normalizedWord);
        return (
          <span key={index} className={isMispronounced ? "text-red-500" : "text-gray-900"}>
            {word}
          </span>
        );
      })}
    </p>
  );
};

export default function PronunciationPage() {
    
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [practiceSentence, setPracticeSentence] = useState<PracticeSentence | null>(null);
  const [feedback, setFeedback] = useState<AssessmentFeedback | null>(null);
  const [recordingStatus, setRecordingStatus] = useState<RecordingStatus>("idle");
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const [isSpeaking, setIsSpeaking] = useState(false);

  const fetchSentence = async () => {
    
    window.speechSynthesis.cancel();
    setIsSpeaking(false);

    setIsLoading(true);
    setError(null);
    setFeedback(null);
    setRecordingStatus("idle");
    try {
      const response = await fetch('/api/pronunciation/sentence');
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Failed to fetch new sentence.');
      setPracticeSentence(data);
    } catch (err: any) {
      setError(err.message);
      toast.error(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSentence();
    
    
    return () => {
      window.speechSynthesis.cancel();
    };
  }, []);

  const handleAssessRecording = async (audioBlob: Blob) => {
    if (!practiceSentence) {
      toast.error("No practice sentence available.");
      setRecordingStatus("idle");
      return;
    }

    const formData = new FormData();
    formData.append('audio_data', audioBlob, 'recording.webm');
    formData.append('target_text', practiceSentence.text);

    try {
      const response = await fetch('/api/pronunciation/assess', {
        method: 'POST',
        body: formData,
      });

      const result = await response.json();
      
      if (!response.ok) {
        throw new Error(result.error || "Assessment failed.");
      }

      setFeedback(result);
      setRecordingStatus("completed");
      toast.success("Assessment complete!");

    } catch (err: any) {
      console.error("Assessment error:", err);
      toast.error(err.message);
      setRecordingStatus("idle"); 
    }
  };
  
  const handleStartRecording = async () => {
    
    window.speechSynthesis.cancel();
    setIsSpeaking(false);

    setFeedback(null);
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        mediaRecorderRef.current = new MediaRecorder(stream);
        audioChunksRef.current = [];

        mediaRecorderRef.current.ondataavailable = (event) => {
          audioChunksRef.current.push(event.data);
        };

        mediaRecorderRef.current.onstop = () => {
          const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
          handleAssessRecording(audioBlob);
        };

        mediaRecorderRef.current.start();
        setRecordingStatus("recording");
        toast.success("Recording started!");

      } catch (err) {
        console.error("Error accessing microphone:", err);
        toast.error("Could not access microphone. Please allow permission.");
      }
    } else {
      toast.error("Audio recording is not supported by your browser.");
    }
  };

  const handleStopRecording = () => {
    if (mediaRecorderRef.current && recordingStatus === "recording") {
      mediaRecorderRef.current.stop();
      mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
      setRecordingStatus("processing");
      toast("Recording stopped. Analyzing...", { icon: '🤖' });
    }
  };

  const handleRecordButtonClick = () => {
    if (recordingStatus === "recording") {
      handleStopRecording();
    } else {
      handleStartRecording();
    }
  };

  const handlePlaySentence = () => {
    if (!practiceSentence?.text || typeof window === 'undefined') return;

    window.speechSynthesis.cancel();

    if (isSpeaking) {
      setIsSpeaking(false);
      return;
    }

    const utterance = new SpeechSynthesisUtterance(practiceSentence.text);
    
    const voices = window.speechSynthesis.getVoices();
    const englishVoice = voices.find(voice => voice.lang.startsWith('en-US')) || voices.find(voice => voice.lang.startsWith('en-'));
    if (englishVoice) {
      utterance.voice = englishVoice;
    }
    
    utterance.onstart = () => {
      setIsSpeaking(true);
    };

    utterance.onend = () => {
      setIsSpeaking(false);
    };
    
    utterance.onerror = () => {
        setIsSpeaking(false);
        toast.error("Sorry, could not play the audio.");
    };

    window.speechSynthesis.speak(utterance);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Toaster position="top-center" />
      <Header />

      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {isLoading ? (
          <div className="text-center py-20">
            <FiRefreshCw className="w-8 h-8 mx-auto animate-spin text-blue-600" />
            <p className="mt-4 text-gray-600">Fetching a new practice sentence...</p>
          </div>
        ) : error ? (
          <div className="text-center py-20 bg-red-50 border border-red-200 rounded-lg p-6">
            <h2 className="text-xl font-bold text-red-700">Something went wrong</h2>
            <p className="mt-2 text-red-600">{error}</p>
            <button
              onClick={fetchSentence}
              className="mt-4 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg"
            >
              Try Again
            </button>
          </div>
        ) : practiceSentence ? (
          <>
            <div className="mb-8">
              <div className="flex items-center justify-between mb-4">
                <h1 className="text-2xl font-bold text-gray-900">Practice Progress</h1>
                <div className="bg-blue-600 text-white px-3 py-1 rounded-full text-sm font-medium">Sentence 1 of 10</div>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3 mb-2">
                <div className="bg-blue-600 h-3 rounded-full" style={{ width: "10%" }}></div>
              </div>
              <p className="text-sm text-gray-600">Current sentence:</p>
            </div>

            <div className="bg-green-50 rounded-lg p-8 mb-8 relative">
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center space-x-2 mb-2">
                    <FaHeadphones className="text-gray-600" />
                    <h2 className="text-xl font-semibold text-gray-900">Practice This Sentence</h2>
                  </div>
                  <p className="text-sm text-gray-600">Beginner • Vowel Sounds</p>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-20 h-20 rounded-full overflow-hidden bg-white shadow-sm">
                    <Image
                      src={"/images/mascot.png"}
                      alt="LissanAI Mascot"
                      width={80}
                      height={80}
                      className="w-full h-full object-contain"
                    />
                  </div>
                  <p className="text-xs text-gray-600">🎧 Listen carefully</p>
                </div>
              </div>
            </div>
            
            <div className="text-center mb-8 bg-white p-6 rounded-lg border">
              <h3 className="text-3xl font-bold text-gray-900 mb-2 leading-relaxed">
                {practiceSentence.text}
              </h3>
            </div>

            <div className="space-y-6 mb-8 flex flex-col items-center">
              <div className="flex flex-col items-center space-y-2">
                <div className="flex items-center space-x-3">
                  <FaHeadphones className="text-blue-600 text-lg" />
                  <span className="font-medium text-gray-900">Step 1: Listen</span>
                </div>
              
                <button 
                  onClick={handlePlaySentence}
                  disabled={isSpeaking}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg flex items-center space-x-2 transition-colors disabled:bg-blue-400 disabled:cursor-not-allowed"
                >
                  <FaPlay className="text-sm" />
                  <span>{isSpeaking ? 'Playing...' : 'Play Sentence'}</span>
                </button>
                
              </div>

              <div className="flex flex-col items-center space-y-2">
                <div className="flex items-center space-x-3">
                  <FaMicrophone className="text-green-600 text-lg" />
                  <span className="font-medium text-gray-900">Step 2: Practice</span>
                </div>
                <button 
                  onClick={handleRecordButtonClick}
                  className={`px-6 py-2 rounded-lg flex items-center space-x-2 transition-all duration-300 font-semibold
                    ${(recordingStatus === "idle" || recordingStatus === "completed") && "bg-gray-100 hover:bg-gray-200 text-gray-700"}
                    ${recordingStatus === "recording" && "bg-red-500 hover:bg-red-600 text-white animate-pulse"}
                    ${recordingStatus === "processing" && "bg-yellow-400 text-yellow-800 cursor-not-allowed"}
                  `}
                  disabled={recordingStatus === "processing"}
                >
                  {(recordingStatus === "idle" || recordingStatus === "completed") && <><FaMicrophone className="text-sm" /><span>Start Recording</span></>}
                  {recordingStatus === "recording" && <><FiSquare className="text-sm" /><span>Stop Recording</span></>}
                  {recordingStatus === "processing" && <><FiRefreshCw className="text-sm animate-spin" /><span>Analyzing...</span></>}
                </button>
              </div>
            </div>

            {feedback && (
              <div className="bg-white rounded-lg border border-gray-200 shadow-sm p-6 mb-8">
                <h2 className="text-xl font-bold text-gray-900 mb-4">Your Feedback</h2>
                <div className="text-center mb-6 bg-gray-50 p-4 rounded-lg">
                  <HighlightedSentence 
                    sentence={practiceSentence.text} 
                    mispronouncedWords={feedback.mispronouncedwords} 
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6 text-center">
                  <div className="bg-blue-50 p-4 rounded-lg">
                    <p className="text-sm text-blue-800 font-semibold">Overall Accuracy</p>
                    <p className="text-4xl font-bold text-blue-600 mt-1">{feedback.overall_accuracy_score}%</p>
                  </div>
                  <div className="bg-red-50 p-4 rounded-lg col-span-1 md:col-span-2">
                    <p className="text-sm text-red-800 font-semibold">Words to Practice</p>
                    {feedback.mispronouncedwords.length > 0 ? (
                      <div className="flex flex-wrap justify-center gap-2 mt-2">
                        {feedback.mispronouncedwords.map((word, index) => (
                          <span key={index} className="bg-red-100 text-red-700 font-mono px-2 py-1 rounded-md text-lg">
                            {word}
                          </span>
                        ))}
                      </div>
                    ) : (
                      <div className="flex items-center justify-center gap-2 text-green-600 mt-2">
                        <FiCheckCircle />
                        <span>Great job! No mistakes found.</span>
                      </div>
                    )}
                  </div>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-800 mb-2">Summary</h3>
                  <p className="text-gray-600">{feedback.full_feedback_summary}</p>
                </div>
              </div>
            )}
          
            <div className="text-center">
              <button 
                onClick={fetchSentence}
                className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg transition-colors"
              >
                Try Another Sentence
              </button>
            </div>
          </>
        ) : null}
      </main>
    </div>
  )
}