

"use client";

import { useState, useEffect, useMemo, Suspense } from "react";
import { useParams, useSearchParams } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import React from 'react';
import Header from "@/components/Header";
import { FiCheck, FiX, FiActivity, FiThumbsUp, FiThumbsDown, FiSend, FiChevronRight, FiAward, FiArrowLeft } from "react-icons/fi";
import toast, { Toaster } from "react-hot-toast";


/* eslint-disable @typescript-eslint/no-explicit-any */

interface LearningPath {
  id: string;
  title: string;
  lesson_ids: string[];
}
interface QuizQuestion {
    id: string;
    text: string;
    options: string[];
}

interface LessonContent {
    id: string;
    title: string;
    description: string;
    content: string;
    quiz: null | {
        id: string;
        title: string;
        questions: QuizQuestion[];
    }
}
interface QuizResult {
    score: number;
    max_score: number;
    percentage: number;
    passed: boolean;
    correct_answers: Record<string, string>;
}


interface QuizProps {
    lesson: LessonContent;
    pathData: LearningPath;
    onQuizPass: () => void; 
}

const Quiz = ({ lesson, pathData, onQuizPass }: QuizProps) => {
    const [answers, setAnswers] = useState<Record<string, string>>({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [results, setResults] = useState<QuizResult | null>(null);

    const handleAnswerChange = (questionId: string, option: string) => {
        setAnswers(prev => ({ ...prev, [questionId]: option }));
    };
    
    const handleSubmit = async () => {
        if (!lesson.quiz) return; 
        setIsSubmitting(true);
        const loadingToast = toast.loading("Submitting your answers...");
        try {
            const response = await fetch(`/api/learning/quizzes/${lesson.quiz.id}/submit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ answers })
            });
            const data = await response.json();
            if (!response.ok) {
                throw new Error(data.error || "Failed to submit quiz.");
            }
            setResults(data);
            toast.success("Quiz submitted successfully!");

            if (data.passed) {
                await fetch(`/api/learning/lessons/${lesson.id}/complete`, { method: 'POST' });
                toast.success("Lesson marked as complete!");
                onQuizPass(); 
            }
        } catch (err: any) {
            toast.error(err.message);
        } finally {
            setIsSubmitting(false);
            toast.dismiss(loadingToast);
        }
    };
    
    const { nextLessonId, isLastLesson } = useMemo(() => {
        if (!pathData || !lesson) return { nextLessonId: null, isLastLesson: false };
        const currentIndex = pathData.lesson_ids.indexOf(lesson.id);
        const isLast = currentIndex === pathData.lesson_ids.length - 1;
        const nextId = isLast ? null : pathData.lesson_ids[currentIndex + 1];
        return { nextLessonId: nextId, isLastLesson: isLast };
    }, [pathData, lesson.id]);

    const getOptionStyle = (questionId: string, option: string) => {
        if (!results) return 'border-gray-300 hover:border-blue-500 cursor-pointer';
        const correctAnswer = results.correct_answers[questionId];
        const userAnswer = answers[questionId];
        
        if (option === correctAnswer) return 'border-green-500 bg-green-50 text-green-800';
        if (option === userAnswer && option !== correctAnswer) return 'border-red-500 bg-red-50 text-red-800';
        return 'border-gray-300 bg-gray-50 text-gray-500';
    };
    
    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-8 mb-10">
            <h2 className="text-2xl font-bold text-gray-800 mb-6">{lesson.quiz?.title}</h2>
            <div className="space-y-8">
                {lesson.quiz?.questions.map((q, index) => (
                    <div key={q.id}>
                        <p className="font-semibold text-gray-700 mb-3">{index + 1}. {q.text}</p>
                        <div className="space-y-2">
                            {q.options.map(option => (
                                <button key={option} onClick={() => !results && handleAnswerChange(q.id, option)} className={`w-full text-left p-3 border-2 rounded-lg transition-colors flex items-center gap-3 ${getOptionStyle(q.id, option)}`} disabled={!!results}>
                                    <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${answers[q.id] === option ? 'border-blue-600 bg-blue-600' : 'border-gray-400'}`}>
                                        {answers[q.id] === option && <div className="w-2 h-2 bg-white rounded-full"></div>}
                                    </div>
                                    <span>{option}</span>
                                </button>
                            ))}
                        </div>
                    </div>
                ))}
            </div>
            {!results && (
                 <button onClick={handleSubmit} disabled={isSubmitting || Object.keys(answers).length !== lesson.quiz?.questions.length} className="mt-8 w-full flex items-center justify-center gap-2 bg-blue-600 text-white font-semibold py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors">
                    {isSubmitting ? <FiActivity className="animate-spin" /> : <FiSend />}
                    {isSubmitting ? 'Submitting...' : 'Submit Answers'}
                </button>
            )}
            {results && (
                <>
                    <div className={`mt-8 p-6 rounded-lg ${results.passed ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'}`}>
                        <div className="flex items-center gap-4">
                            <div className="flex-shrink-0">{results.passed ? <FiThumbsUp className="w-10 h-10 text-green-500" /> : <FiThumbsDown className="w-10 h-10 text-red-500" />}</div>
                            <div>
                                <h3 className={`text-xl font-bold ${results.passed ? 'text-green-800' : 'text-red-800'}`}>{results.passed ? 'Congratulations, you passed!' : 'Keep trying!'}</h3>
                                <p className="text-2xl font-semibold">{results.score} / {results.max_score} ({results.percentage}%)</p>
                            </div>
                        </div>
                    </div>
                    {results.passed && (
                        <div className="mt-8 text-center">
                            {isLastLesson ? (
                                <div className="bg-green-100 border border-green-300 text-green-800 font-semibold p-4 rounded-lg inline-flex items-center gap-3">
                                    <FiAward />
                                    <span>Congratulations! You have completed the path: {pathData.title}</span>
                                </div>
                            ) : (
                                <Link href={`/learn/lesson/${nextLessonId}?pathId=${pathData.id}`} className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg inline-flex items-center gap-2 transition-colors">
                                    <span>Next Lesson</span>
                                    <FiChevronRight />
                                </Link>
                            )}
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

interface MarkAsCompleteProps {
    lessonId: string;
    onComplete: () => void;
}
const MarkAsComplete = ({ lessonId, onComplete }: MarkAsCompleteProps) => {
    const [isCompleting, setIsCompleting] = useState(false);
    const handleComplete = async () => {
        setIsCompleting(true);
        const loadingToast = toast.loading("Marking as complete...");
        try {
            const response = await fetch(`/api/learning/lessons/${lessonId}/complete`, { 
                method: 'POST' 
            });
            if (!response.ok) {
                const data = await response.json();
                throw new Error(data.error || "Failed to mark as complete.");
            }
            toast.success("Lesson marked as complete!");
            onComplete();
        } catch (err: any) {
            toast.error(err.message);
        } finally {
            setIsCompleting(false);
            toast.dismiss(loadingToast);
        }
    };
    return (
        <div className="text-center my-8">
            <button
                onClick={handleComplete}
                disabled={isCompleting}
                className="bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-8 rounded-lg inline-flex items-center gap-2 transition-colors disabled:opacity-50"
            >
                {isCompleting ? <FiActivity className="animate-spin" /> : <FiCheck />}
                <span>{isCompleting ? 'Saving...' : 'Mark as Completed'}</span>
            </button>
        </div>
    );
};


function LessonDetailContent() {
  const params = useParams();
  const searchParams = useSearchParams();
  const lessonId = params.lessonId as string;
  const pathId = searchParams.get('pathId');
  
  const [lesson, setLesson] = useState<LessonContent | null>(null);
  const [pathData, setPathData] = useState<LearningPath | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isCompleted, setIsCompleted] = useState(false);

  useEffect(() => {
    if (lessonId && pathId) {
      const fetchData = async () => {
        setIsLoading(true);
        setError(null);
        setIsCompleted(false);
        try {
          const [lessonRes, pathRes] = await Promise.all([
            fetch(`/api/learning/lessons/${lessonId}`),
            fetch(`/api/learning/paths/${pathId}`)
          ]);
          if (!lessonRes.ok) {
            const lessonError = await lessonRes.json(); throw new Error(lessonError.error || 'Failed to fetch lesson content.');
          }
          if (!pathRes.ok) {
             const pathError = await pathRes.json(); throw new Error(pathError.error || 'Failed to fetch learning path data.');
          }
          const lessonData = await lessonRes.json();
          const fullPathData = await pathRes.json();
          setLesson(lessonData);
          setPathData(fullPathData);
        } catch (err: any) {
          setError(err.message);
        } finally {
          setIsLoading(false);
        }
      };
      fetchData();
    }
  }, [lessonId, pathId]);
  
  const { nextLessonId, isLastLesson } = useMemo(() => {
    if (!pathData || !lessonId) return { nextLessonId: null, isLastLesson: false };
    const currentIndex = pathData.lesson_ids.indexOf(lessonId);
    const isLast = currentIndex === pathData.lesson_ids.length - 1;
    const nextId = isLast ? null : pathData.lesson_ids[currentIndex + 1];
    return { nextLessonId: nextId, isLastLesson: isLast };
  }, [pathData, lessonId]);

  if (isLoading) { return ( <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center"><FiActivity className="w-8 h-8 mx-auto animate-spin text-blue-500" /><p className="mt-2 text-gray-600">Loading Lesson...</p></main> ); }
  if (error || !lesson || !pathData) { return ( <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center"><h1 className="text-2xl font-bold text-red-700">An Error Occurred</h1><p className="mt-4 text-red-600">{error || "Could not load the lesson."}</p><Link href="/learn" className="mt-6 inline-block bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700">Back to All Lessons</Link></main> ); }

  return (
    <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <Link href="/learn" className="text-sm font-semibold text-blue-600 hover:underline mb-2 inline-flex items-center gap-2"><FiArrowLeft />Back to Learning Paths</Link>
        <h1 className="text-4xl font-extrabold text-gray-900 mt-2">{lesson.title}</h1>
      </div>
      <div className="relative bg-white rounded-xl shadow-sm border-2 border-blue-200 p-6 pr-28 sm:pr-32 mb-12"><p className="text-gray-700 max-w-lg">{lesson.description}</p><div className="absolute -top-6 -right-6 sm:-right-8 w-24 h-24 sm:w-28 sm:h-28 pointer-events-none"><div className="relative w-full h-full p-1.5 bg-gradient-to-tr from-green-400 to-white rounded-full shadow-lg"><div className="w-full h-full bg-white rounded-full"><Image src="/images/mascot.png" alt="Mascot" width={112} height={112} className="w-full h-full object-contain rounded-full" /></div></div></div></div>
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-8 mb-10"><h2 className="text-2xl font-bold text-gray-800 mb-4">Lesson Content</h2><div className="prose max-w-none"><p>{lesson.content}</p></div></div>
      
      {!isCompleted && (
        <>
            {lesson.quiz ? (
                <Quiz 
                    lesson={lesson}
                    pathData={pathData}
                    onQuizPass={() => setIsCompleted(true)}
                />
            ) : (
                <MarkAsComplete 
                    lessonId={lesson.id} 
                    onComplete={() => setIsCompleted(true)} 
                />
            )}
        </>
      )}

      {isCompleted && (
        <div className="mt-8 text-center">
          {isLastLesson ? (
            <div className="bg-green-100 border border-green-300 text-green-800 font-semibold p-4 rounded-lg inline-flex items-center gap-3">
              <FiAward />
              <span>Congratulations! You have completed the path: {pathData.title}</span>
            </div>
          ) : (
            <Link 
              href={`/learn/lesson/${nextLessonId}?pathId=${pathData.id}`}
              className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg inline-flex items-center gap-2 transition-colors"
            >
              <span>Next Lesson</span>
              <FiChevronRight />
            </Link>
          )}
        </div>
      )}
    </main>
  );
}

export default function LessonDetailPage() {
    return (
        <div className="min-h-screen bg-gray-50">
            <Toaster position="top-center" />
            <Header />
            <Suspense fallback={<main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center"><FiActivity className="w-8 h-8 mx-auto animate-spin text-blue-500" /><p className="mt-2 text-gray-600">Loading Lesson...</p></main>}>
                <LessonDetailContent />
            </Suspense>
        </div>
    )
}