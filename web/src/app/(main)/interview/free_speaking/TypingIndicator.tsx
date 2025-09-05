"use client";
import React from "react";
import { motion, useReducedMotion } from "framer-motion";

// -------------------- THINKING: Pulsing pips --------------------
export default function ThinkingPips() {
  const shouldReduce = useReducedMotion();
  const pips = [0, 1, 2];

  return (
    <div className="flex items-center gap-2">
      {pips.map((_, i) => (
        <motion.div
          key={i}
          className="h-3 w-3 rounded-full bg-blue-500 dark:bg-blue-400"
          animate={shouldReduce ? {} : { opacity: [0.4, 1, 0.4] }}
          transition={{ duration: 1.2, repeat: Infinity, delay: i * 0.2 }}
        />
      ))}
    </div>
  );
}
