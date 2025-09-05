"use client";
import React, { useEffect, useRef } from "react";
import styles from "./VoiceCircle.module.css"; // You will also need the CSS module for this

type ConversationState = "idle" | "recording";

interface VoiceCircleProps {
  state: ConversationState;
  onClick: () => void;
  userVolume: number;
}

const VoiceCircle: React.FC<VoiceCircleProps> = ({
  state,
  onClick,
  userVolume,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (state === "recording" && containerRef.current) {
      const scale = 1 + userVolume * 0.15;
      containerRef.current.style.transform = `scale(${scale})`;
    } else if (containerRef.current) {
      containerRef.current.style.transform = `scale(1)`;
    }
  }, [userVolume, state]);

  const stateClass =
    styles[`state${state.charAt(0).toUpperCase() + state.slice(1)}`];

  return (
    <div
      ref={containerRef}
      className={`${styles.container} ${stateClass}`}
      onClick={onClick}
    >
      <svg className={styles.blobSvg} viewBox="0 0 100 100">
        <path
          className={styles.blobPath}
          d="M 50, 50 m -48, 0 a 48,48 0 1,0 96,0 a 48,48 0 1,0 -96,0"
        />
      </svg>
      <svg
        className={styles.micIcon}
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 384 512"
      >
        <path d="M192 0C139 0 96 43 96 96V256c0 53 43 96 96 96s96-43 96-96V96c0-53-43-96-96-96zM64 216c0-13.3-10.7-24-24-24s-24 10.7-24 24v40c0 89.1 66.2 162.7 152 174.4V464H120c-13.3 0-24 10.7-24 24s10.7 24 24 24h144c13.3 0 24-10.7 24-24s-10.7-24-24-24H200V430.4c85.8-11.7 152-85.3 152-174.4V216c0-13.3-10.7-24-24-24s-24 10.7-24 24v40c0 70.7-57.3 128-128 128s-128-57.3-128-128V216z" />
      </svg>
    </div>
  );
};

export default VoiceCircle;
