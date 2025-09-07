


"use client";

import { useState, useEffect, Suspense } from 'react';
import { useParams } from 'next/navigation';
import Header from '@/components/Header';
import { FiBookOpen, FiChevronRight, FiCheckCircle, FiActivity, FiArrowLeft } from 'react-icons/fi';
import Link from 'next/link';

/* eslint-disable @typescript-eslint/no-explicit-any */
import { Toaster } from 'react-hot-toast';



interface LessonInfo {
  id: string;
  title: string;
  is_completed: boolean;
}
interface PathDetails {
  id: string;
  title: string;
  description: string;
  lessons: LessonInfo[];
}


const LessonListItem = ({ id, title, is_completed, pathId }: LessonInfo & { pathId: string }) => (
  <Link 
    href={`/learn/lesson/${id}?pathId=${pathId}`}
    className="block"
  >
    <div className="bg-white p-4 rounded-lg border border-gray-200 flex items-center justify-between hover:bg-gray-50 hover:border-blue-500 transition-colors shadow-sm">
      <div className="flex items-center gap-4">
        <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${is_completed ? 'bg-green-500' : 'bg-gray-300'}`}>
          <FiCheckCircle className="text-white" />
        </div>
        <div>
          <h3 className="font-semibold text-gray-800">{title}</h3>
        </div>
      </div>
      <FiChevronRight className="text-gray-400" />
    </div>
  </Link>
);



function PathDetailContent() {
    const params = useParams();
    const pathId = params.pathId as string;

    const [pathData, setPathData] = useState<PathDetails | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (pathId) {
            const fetchPathDetails = async () => {
                setIsLoading(true);
                setError(null);
                try {

                  const [pathRes, progressRes] = await Promise.all([
                        fetch(`/api/learning/paths/${pathId}`),
                        fetch(`/api/learning/paths/${pathId}/progress`)
                    ]);

                    if (!pathRes.ok) {
                        const pathError = await pathRes.json();
                        throw new Error(pathError.error || 'Failed to fetch path details.');
                    }
                    if (!progressRes.ok) {
                        const progressError = await progressRes.json();
                        throw new Error(progressError.error || 'Failed to fetch user progress.');
                    }

                    const pathData = await pathRes.json();
                    const progressData = await progressRes.json();
                    

                    const completedSet = new Set(progressData.completed_lessons || []);


                    const lessonPromises = pathData.lesson_ids.map((lessonId: string) =>
                        fetch(`/api/learning/lessons/${lessonId}`).then(res => {
                            if (!res.ok) {
                                console.error(`Failed to fetch details for lesson ${lessonId}`);
                                return null; 
                                
                            }
                            return res.json();
                        })
                    );
                    const lessonsDetails = await Promise.all(lessonPromises);
                    
                    const formattedLessons = lessonsDetails
                        .filter(lesson => lesson && lesson.id) 
                        
                        .map((lesson: any) => ({
                            id: lesson.id,
                            title: lesson.title, 
                            is_completed: completedSet.has(lesson.id) 
                            
                        }));

                    setPathData({
                      ...pathData,
                      lessons: formattedLessons,
                    });

                } catch (err: any) {
                    setError(err.message);
                } finally {
                    setIsLoading(false);
                }
            };
            fetchPathDetails();
        }
    }, [pathId]);

    if (isLoading) {
      return (
          <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center">
              <FiActivity className="w-8 h-8 mx-auto animate-spin text-blue-500" />
              <p className="mt-2 text-gray-600">Loading Path Details...</p>
          </main>
      );
    }

    if (error || !pathData) {
      return (
          <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center">
            <h1 className="text-2xl font-bold text-red-700">An Error Occurred</h1>
            <p className="mt-4 text-red-600">{error || "Could not load the learning path."}</p>
            <Link href="/learn" className="mt-6 inline-block bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700">
              Back to All Lessons
            </Link>
          </main>
      );
    }

    return (
        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
            <div className="mb-8">
                <Link href="/learn" className="text-sm font-semibold text-blue-600 hover:underline mb-2 inline-flex items-center gap-2">
                    <FiArrowLeft />
                    Back to Learning Paths
                </Link>
                <h1 className="text-4xl font-extrabold text-gray-900 mt-2">{pathData.title}</h1>
                <p className="mt-2 text-lg text-gray-600">{pathData.description}</p>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                <div className="flex items-center gap-3 mb-4">
                    <FiBookOpen className="text-blue-500" />
                    <h2 className="text-xl font-bold text-gray-800">Lessons in this Path</h2>
                </div>
                <div className="space-y-3">
                    {pathData.lessons.map(lesson => (
                        <LessonListItem key={lesson.id} {...lesson} pathId={pathData.id} />
                    ))}
                </div>
            </div>
        </main>
    );
}



export default function LessonListPage() {
    return (
        <div className="min-h-screen bg-gray-50">
            <Toaster position="top-center" />
            <Header />
            <Suspense fallback={
                <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center">
                    <FiActivity className="w-8 h-8 mx-auto animate-spin text-blue-500" />
                    <p className="mt-2 text-gray-600">Loading...</p>
                </main>
            }>
                <PathDetailContent />
            </Suspense>
        </div>
    );
}