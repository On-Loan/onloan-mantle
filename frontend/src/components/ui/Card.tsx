import type { HTMLAttributes, ReactNode } from 'react';
import { motion } from 'framer-motion';
import type { LucideIcon } from 'lucide-react';

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'standard' | 'elevated' | 'stat';
  title?: string;
  icon?: LucideIcon;
  children: ReactNode;
}

export const Card = ({
  variant = 'standard',
  title,
  icon: Icon,
  children,
  className = '',
}: CardProps) => {
  const baseStyles = 'rounded-2xl bg-white dark:bg-gray-900 transition-all duration-200';

  const variantStyles = {
    standard: 'border border-gray-200 dark:border-gray-800 p-6',
    elevated: 'shadow-lg hover:shadow-xl p-6',
    stat: 'border border-gray-200 dark:border-gray-800 p-8 text-center',
  };

  if (variant === 'stat') {
    return (
      <motion.div
        className={`${baseStyles} ${variantStyles[variant]} ${className}`}
        whileHover={{ y: -2 }}
      >
        {Icon && (
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900/20">
            <Icon className="h-7 w-7 text-primary-600 dark:text-primary-400" />
          </div>
        )}
        {title && (
          <h3 className="mb-2 text-sm font-medium text-gray-600 dark:text-gray-400 uppercase tracking-wide">
            {title}
          </h3>
        )}
        <div className="text-3xl font-bold text-gray-900 dark:text-gray-100">{children}</div>
      </motion.div>
    );
  }

  return (
    <motion.div
      className={`${baseStyles} ${variantStyles[variant]} ${className}`}
      whileHover={variant === 'elevated' ? { y: -4 } : undefined}
    >
      {title && (
        <div className="mb-4 flex items-center gap-3">
          {Icon && <Icon className="h-5 w-5 text-primary-600 dark:text-primary-400" />}
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">{title}</h3>
        </div>
      )}
      <div className="text-gray-700 dark:text-gray-300">{children}</div>
    </motion.div>
  );
};
