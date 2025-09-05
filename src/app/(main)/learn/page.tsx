/* eslint-disable @typescript-eslint/no-explicit-any */

"use client";

import { useState, useEffect } from 'react';
import Image from 'next/image';
import Header from '@/components/Header';
import { FiBookOpen, FiZap, FiCheckCircle, FiClock, FiActivity, FiArrowRight } from 'react-icons/fi';
import React from 'react';
import Link from 'next/link';

interface LearningPath {
  id: string;
  title: string;
  description: string;
  level: string;
  category: string;
  total_lessons: number;
  user_progress: number;
}



const PathCard = ({ id, title, description, level, total_lessons, user_progress }: LearningPath) => {
  const progressPercentage = Math.round(user_progress * 100);
  
  type LevelKey = 'beginner' | 'intermediate' | 'advanced';

  const levelColor: Record<LevelKey, string> = {
    beginner: 'bg-green-100 text-green-700',
    intermediate: 'bg-blue-100 text-blue-700',
    advanced: 'bg-red-100 text-red-700',
  };

  const levelKey = level.toLowerCase() as LevelKey;

  return (
    <Link 
      href={`/learn/path/${id}`}
      className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col text-left hover:border-blue-500 hover:shadow-lg transition-all duration-300 group"
    >
      <div className="flex justify-between items-center mb-4">
        <span className={`px-2 py-1 text-xs font-semibold rounded-md capitalize ${levelColor[levelKey] || 'bg-gray-100 text-gray-700'}`}>{level}</span>
        <div className="flex items-center text-sm text-gray-500">
          <FiBookOpen className="mr-1.5" />
          <span>{total_lessons} Lessons</span>
        </div>
      </div>
      
      <h3 className="text-lg font-bold text-gray-800 mb-2 flex-grow">{title}</h3>
      <p className="text-sm text-gray-600 mb-6">{description}</p>
      
      <div className="w-full bg-gray-200 rounded-full h-2 mb-1">
        <div 
          className="bg-blue-600 h-2 rounded-full" 
          style={{ width: `${progressPercentage}%` }}
        ></div>
      </div>
      <p className="text-xs text-gray-500 mb-6">{progressPercentage}% Complete</p>
      
      <div className="w-full mt-auto flex items-center justify-center gap-2 bg-blue-600 text-white font-semibold py-2.5 rounded-lg group-hover:bg-blue-700 transition-colors">
        <span>Continue Path</span>
        <FiArrowRight />
      </div>
    </Link>
  );
};



export default function LearnPage() {
  const [paths, setPaths] = useState<LearningPath[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchPaths = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await fetch('/api/learning/paths');
        const data = await response.json();
        if (!response.ok) {
          throw new Error(data.error || 'Failed to fetch learning paths.');
        }
        setPaths(data);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };

    fetchPaths();
  }, []);

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-extrabold text-gray-900">Your Learning Paths</h1>
          <p className="mt-2 max-w-2xl mx-auto text-lg text-gray-600">
            Choose a path to improve your English skills with interactive lessons and quizzes. Learn at your own pace with personalized feedback.
          </p>
        </div>

        {isLoading ? (
          <div className="text-center py-10">
            <FiActivity className="w-8 h-8 mx-auto animate-spin text-blue-500" />
            <p className="mt-2 text-gray-600">Loading Learning Paths...</p>
          </div>
        ) : error ? (
          <div className="text-center py-10 bg-red-50 border border-red-200 rounded-lg">
            <h2 className="text-xl font-bold text-red-700">Could not load paths</h2>
            <p className="mt-1 text-red-600">{error}</p>
          </div>
        ) : (

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {Array.isArray(paths) && paths.length > 0 ? (
              paths.map(path => <PathCard key={path.id} {...path} />)
            ) : (
              <div className="col-span-3 text-center py-10 text-gray-500">
                <p>No learning paths are available at the moment.</p>
              </div>
            )}
          </div>

)}
      </main>
    </div>
  );
}