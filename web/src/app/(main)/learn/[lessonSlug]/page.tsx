
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import React from 'react';
import Header from "@/components/Header";
import { FiChevronDown, FiHash } from "react-icons/fi";
import { FaLightbulb } from "react-icons/fa";

import { learnPageLessons, learnPageTips, type Lesson, type SubTopic } from "@/constants/index";


const slugify = (text: string) =>
  text
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^\w-]+/g, '');


    
interface AccordionItemProps {
    topic: SubTopic;
    isOpen: boolean;
    onToggle: () => void;
}

const AccordionItem = ({ topic, isOpen, onToggle }: AccordionItemProps) => (
    <div>
        <button 
            onClick={onToggle}
            className="w-full text-left bg-blue-100/60 border border-blue-200 rounded-lg p-4 flex justify-between items-center hover:bg-blue-100 transition-colors shadow-sm shadow-blue-100"
        >
            <h3 className="font-bold text-gray-800">{topic.title}</h3>
            <FiChevronDown className={`text-gray-600 w-6 h-6 flex-shrink-0 transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`} />
        </button>
        
        <div className={`overflow-hidden transition-all duration-500 ease-in-out ${isOpen ? 'max-h-screen' : 'max-h-0'}`}>
            <div className="p-4 pt-4">
                <p className="text-gray-600 mb-4">{topic.explanation}</p>
                
                {topic.examples && topic.examples.length > 0 && (
                    <div>
                        <h4 className="font-semibold text-gray-700 mb-2">Examples:</h4>
                        <ul className="space-y-2">
                            {topic.examples.map((example, index) => (
                                <li key={index} className="flex items-start gap-3">
                                    <FiHash className="w-4 h-4 text-blue-500 mt-1 flex-shrink-0" />
                                    <span className="text-gray-600 italic">{example}</span>
                                </li>
                            ))}
                        </ul>
                    </div>
                )}
            </div>
        </div>
    </div>
);


export default function LessonDetailPage() {
  const params = useParams();
  const lessonSlug = params.lessonSlug as string;
  const [openAccordion, setOpenAccordion] = useState<string | null>(null);

  const lesson = learnPageLessons.find(
    (l) => slugify(l.title) === lessonSlug
  );

  if (!lesson) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 text-center">
          <h1 className="text-2xl font-bold">Lesson Not Found</h1>
          <p className="mt-4">We could not find the lesson you were looking for.</p>
          <Link href="/learn" className="mt-6 inline-block bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700">
            Back to All Lessons
          </Link>
        </main>
      </div>
    );
  }

  const pageTitle = lesson.title;

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        
        <div className="text-center mb-10">
          <h1 className="text-4xl font-extrabold text-gray-900">{pageTitle}</h1>
        </div>


        <div className="relative bg-blue-100/50 border border-blue-200 rounded-2xl p-6 pr-28 sm:pr-32 mb-12 shadow-sm">
            <p className="text-gray-700 max-w-lg">
                Welcome to the {pageTitle} section! Here you will learn essential concepts to improve your English communication skills.
            </p>


            <div className="absolute -top-6 -right-6 sm:-right-8 w-24 h-24 sm:w-28 sm:h-28 pointer-events-none">
              
              
              <div className="w-full h-full p-1.5 bg-gradient-to-tr from-green-400 to-white rounded-full shadow-lg">
                
                
                <div className="w-full h-full bg-white rounded-full">
                
                
                  <Image
                      src="/images/mascot.png"
                      alt="Mascot"
                      width={112}
                      height={112}
                      className="w-full h-full object-contain rounded-full"
                  />
                </div>
              </div>
            </div>
        </div>


        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-8 mb-10">
            <div className="space-y-4">
                {lesson.subTopics.map((topic) => (
                    <AccordionItem 
                        key={topic.title} 
                        topic={topic}
                        isOpen={openAccordion === topic.title}
                        onToggle={() => setOpenAccordion(openAccordion === topic.title ? null : topic.title)}
                    />
                ))}
            </div>
        </div>

        <div className="mt-12 bg-white rounded-xl shadow-sm border-2 border-blue-200 p-6 relative">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
              <div className="flex-grow w-full">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-8 h-8 flex items-center justify-center bg-yellow-100 rounded-full">
                      <FaLightbulb className="w-5 h-5 text-yellow-500" />
                    </div>
                    <h3 className="text-lg font-bold text-gray-800">Tips for Practice</h3>
                  </div>
                  <ul className="space-y-3 pl-4">
                      {learnPageTips.map(tip => (
                          <li key={tip} className="flex items-start gap-3">
                              <div className="w-5 h-5 flex items-center justify-center bg-yellow-100 rounded-full flex-shrink-0 mt-0.5">
                                <FaLightbulb className="w-3 h-3 text-yellow-500" />
                              </div>
                              <span className="text-sm text-gray-600">{tip}</span>
                          </li>
                      ))}
                  </ul>
              </div>

              <div className="relative flex-shrink-0 flex items-center justify-center md:justify-end mt-6 md:mt-0 w-full md:w-auto">
                  <div className="bg-blue-100 text-blue-800 font-semibold py-3 px-5 rounded-xl shadow-sm mr-4">
                      Lets Learn Together!
                  </div>
                  <div className="w-24 h-24">
                    <Image 
                        src="/images/mascot.png" 
                        alt="Mascot encouraging learning" 
                        width={96} 
                        height={96} 
                        className="w-full h-full object-contain" 
                    />
                  </div>
              </div>
          </div>
        </div>

      </main>
    </div>
  );
}