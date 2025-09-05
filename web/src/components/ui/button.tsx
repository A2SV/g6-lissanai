import React from "react";

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  children: React.ReactNode;
};

export function Button({ children, ...props }: ButtonProps) {
  return (
    <button
      {...props}
      className={`bg-[#337fa1] hover:bg-[#2c6e91] text-white font-semibold px-4 py-2 rounded-lg transition-colors ${
        props.className ?? ""
      }`}
    >
      {children}
    </button>
  );
}
