"use client";
import React from "react";
import { motion, useReducedMotion } from "framer-motion";

interface RespondingBarsProps {
  count?: number;
  maxHeight?: number;
}

const RespondingBars: React.FC<RespondingBarsProps> = ({
  count = 4,
  maxHeight = 48, // Increased default height for more visual impact
}) => {
  const shouldReduceMotion = useReducedMotion();

  const seeds = React.useMemo(
    () =>
      Array.from({ length: count }, (_, i) => 0.5 + ((i * 37.1) % 50) / 100),
    [count]
  );

  return (
    // This outer container no longer uses a gap.
    <div
      className="flex items-center justify-center"
      style={{ height: maxHeight }}
      aria-label="AI speaking animation"
      role="img"
    >
      {seeds.map((seed, i) => (
        // --- FIX 1: Each bar is in a static wrapper ---
        // This wrapper creates the spacing and locks the bar's horizontal position.
        <div key={i} className="w-6 h-full flex justify-center items-center">
          <motion.div
            className="w-4 rounded-full bg-blue-500"
            // The bar itself fills the wrapper's height and is scaled
            style={{ height: "100%" }}
            animate={
              shouldReduceMotion
                ? { scaleY: 0.15 }
                : {
                    // --- FIX 2: Increased animation range ---
                    // The bar now shrinks much smaller (0.15) and grows taller (up to 1.0)
                    scaleY: [
                      0.15, // Start very small
                      0.8 + seed * 0.2, // Grow to a tall, random height
                      0.15, // Shrink back down
                    ],
                  }
            }
            transition={{
              duration: 1.2 + seed * 0.6, // Slower duration from previous request
              repeat: Infinity,
              repeatType: "mirror",
              ease: "easeInOut",
              delay: i * 0.1,
            }}
          />
        </div>
      ))}
    </div>
  );
};

export default RespondingBars;
