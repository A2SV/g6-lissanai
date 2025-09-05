import React from "react";

type CardProps = React.HTMLAttributes<HTMLDivElement> & {
  children: React.ReactNode;
};

export function Card({ children, className = "", ...props }: CardProps) {
  return (
    <div
      {...props}
      className={`bg-white rounded-xl shadow border border-gray-200 ${className}`}
    >
      {children}
    </div>
  );
}

type CardContentProps = React.HTMLAttributes<HTMLDivElement> & {
  children: React.ReactNode;
};

export function CardContent({
  children,
  className = "",
  ...props
}: CardContentProps) {
  return (
    <div {...props} className={`p-4 ${className}`}>
      {children}
    </div>
  );
}

type CardHeaderProps = React.HTMLAttributes<HTMLDivElement> & {
  children: React.ReactNode;
};

export function CardHeader({
  children,
  className = "",
  ...props
}: CardHeaderProps) {
  return (
    <div
      {...props}
      className={`px-4 pt-4 pb-2 border-b border-gray-100 ${className}`}
    >
      {children}
    </div>
  );
}

type CardTitleProps = React.HTMLAttributes<HTMLHeadingElement> & {
  children: React.ReactNode;
};

export function CardTitle({
  children,
  className = "",
  ...props
}: CardTitleProps) {
  return (
    <h3 {...props} className={`text-lg text-black font-semibold ${className}`}>
      {children}
    </h3>
  );
}
