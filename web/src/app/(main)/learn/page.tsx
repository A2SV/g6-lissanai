"use client";

import { useState, useMemo } from 'react';
import Image from 'next/image';
import Header from '@/components/Header';
import { FiClock, FiPlayCircle, FiChevronDown } from 'react-icons/fi'; 

import { FaLightbulb } from 'react-icons/fa';
import React from 'react';
import Link from 'next/link';

import {
  learnPageStats,
  learnPageFilters,
  learnPageLessons,
  learnPageTips,
  type Stat,
  type Filter,
  type Lesson
} from '@/constants/index';


const StatCard = ({ icon, value, label, color, bgColor }: Stat) => (
  <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 flex flex-col items-center justify-center text-center">
    <div className={`w-12 h-12 rounded-full flex items-center justify-center mb-3 ${bgColor}`}>
      {icon}
    </div>
    <p className={`text-2xl font-bold ${color}`}>{value}</p>
    <p className="text-sm text-gray-500">{label}</p>
  </div>
);
const FilterChip = ({ label, count, isActive, onClick }: Filter & { isActive: boolean, onClick: () => void }) => (
  <button 
    onClick={onClick}
    className={`px-4 py-1.5 rounded-lg text-sm font-semibold flex items-center gap-2 transition-colors ${
      isActive 
        ? 'bg-gray-800 text-white' 
        : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'
    }`}>
    <span>{label}</span>
    <span className={`text-xs px-1.5 py-0.5 rounded-md ${
      isActive ? 'bg-gray-600 text-gray-200' : 'bg-gray-100 text-gray-500'
    }`}>{count}</span>
  </button>
);
const slugify = (text: string) =>
  text
    .toLowerCase()
    .replace(/\s+/g, '-') 
    .replace(/[^\w-]+/g, ''); 
const LessonCard = ({ level, title, description, time }: Lesson) => {
  const levelColor = {
    Beginner: 'bg-green-100 text-green-700',
    Intermediate: 'bg-blue-100 text-blue-700',
    Advanced: 'bg-red-100 text-red-700',
  };
  const lessonSlug = slugify(title);
  return (
    <Link 
      href={`/learn/${lessonSlug}`}
      className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 flex flex-col text-left hover:border-teal-500 hover:shadow-md transition-all duration-300 group"
    >
      <div className="mb-3">
        <span className={`px-2 py-1 text-xs font-semibold rounded-md ${levelColor[level]}`}>{level}</span>
      </div>
      <h3 className="text-lg font-bold text-gray-800 mb-2">{title}</h3>
      <p className="text-sm text-gray-600 mb-4 flex-grow">{description}</p>
      <div className="flex items-center text-gray-500 text-sm mb-6">
        <FiClock className="mr-2" />
        <span>{time} min</span>
      </div>
      <div className="w-full flex items-center justify-center gap-2 bg-teal-600 text-white font-semibold py-2.5 rounded-lg group-hover:bg-teal-700 transition-colors">
        <FiPlayCircle />
        <span>Start Lesson</span>
      </div>
    </Link>
  );
};


export default function LearnPage() {
  const [activeFilter, setActiveFilter] = useState('All Lessons');
  const [showAll, setShowAll] = useState(false);

  const filteredLessons = useMemo(() => {
    const allFiltered = activeFilter === 'All Lessons'
      ? learnPageLessons
      : learnPageLessons.filter(lesson => lesson.category === activeFilter);
    
    return showAll ? allFiltered : allFiltered.slice(0, 10);
  }, [activeFilter, showAll]);

  const totalFilteredCount = useMemo(() => {
     if (activeFilter === 'All Lessons') {
      return learnPageLessons.length;
    }
    return learnPageLessons.filter(lesson => lesson.category === activeFilter).length;
  }, [activeFilter]);
  
  const handleFilterClick = (filterLabel: string) => {
    setActiveFilter(filterLabel);
    setShowAll(false);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-extrabold text-gray-900">Learn English</h1>
          <p className="mt-2 max-w-2xl mx-auto text-lg text-gray-600">
            Improve your English skills with interactive lessons designed specifically for Ethiopian learners. Learn at your own pace with personalized feedback.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
          {learnPageStats.map(stat => <StatCard key={stat.label} {...stat} />)}
        </div>

        <div className="flex flex-wrap items-center gap-2 mb-10">
          {learnPageFilters.map(filter => (
            <FilterChip 
              key={filter.label} 
              {...filter} 
              isActive={activeFilter === filter.label}
              onClick={() => handleFilterClick(filter.label)} 
            />
          ))}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredLessons.map(lesson => <LessonCard key={lesson.title} {...lesson} />)}
        </div>
      
          <div className="mt-12 text-center">
          {!showAll && totalFilteredCount > 10 && (
            <button
              onClick={() => setShowAll(true)}
              className="bg-white border border-gray-300 text-gray-700 font-semibold py-2 px-6 rounded-lg hover:bg-gray-50 transition-colors flex items-center gap-2 mx-auto"
            >
              <span>Show More</span>
              <FiChevronDown />
            </button>
          )}
        </div>

    <div className="bg-white rounded-xl shadow-sm border border-blue-200 p-6 flex flex-col md:flex-row items-center gap-6 mt-12">
            <div className="flex-grow">
                <h3 className="text-lg font-bold text-gray-800 mb-4">Tips for Practice</h3>
                <ul className="space-y-3">
                    {learnPageTips.map(tip => (
                        <li key={tip} className="flex items-start gap-3">
                            <FaLightbulb className="w-5 h-5 text-yellow-400 mt-0.5 flex-shrink-0" />
                            <span className="text-sm text-gray-600">{tip}</span>
                        </li>
                    ))}
                </ul>
            </div>
            <div className="flex-shrink-0 text-center">
                <button className="bg-blue-600 text-white font-semibold py-2.5 px-6 rounded-lg hover:bg-blue-700 transition-colors mb-4">
                    Lets Learn Together!
                </button>
                <div className="relative h-64 w-64 md:h-80 md:w-80 mx-auto flex items-center justify-center">
                        <img
                            src="/videos/readingmascot.gif" 
                            alt="LissanAI Mascot Animation" 
                            className="absolute inset-0 w-full h-full object-contain" // Keep consistent styling
                        />
                    </div>
            </div>
        </div>
      </main>
    </div>
  );
}