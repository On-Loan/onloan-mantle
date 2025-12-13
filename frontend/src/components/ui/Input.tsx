import { forwardRef } from 'react';
import type { InputHTMLAttributes } from 'react';
import { AlertCircle, CheckCircle } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
  icon?: LucideIcon;
  success?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, helperText, icon: Icon, success, className = '', ...props }, ref) => {
    const hasError = !!error;
    const showSuccess = success && !hasError;

    const baseStyles =
      'w-full rounded-xl border bg-white dark:bg-gray-900 px-4 py-2.5 text-gray-900 dark:text-gray-100 transition-all duration-200 placeholder:text-gray-400 dark:placeholder:text-gray-600 focus:outline-none focus:ring-2 disabled:cursor-not-allowed disabled:opacity-50';

    const stateStyles = hasError
      ? 'border-red-300 dark:border-red-800 focus:border-red-500 focus:ring-red-500/20'
      : showSuccess
      ? 'border-green-300 dark:border-green-800 focus:border-green-500 focus:ring-green-500/20'
      : 'border-gray-300 dark:border-gray-700 focus:border-primary-500 focus:ring-primary-500/20';

    const paddingStyles = Icon ? 'pl-11' : '';

    return (
      <div className={`space-y-1.5 ${className}`}>
        {label && (
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
            {label}
          </label>
        )}
        <div className="relative">
          {Icon && (
            <div className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2">
              <Icon className="h-5 w-5 text-gray-400 dark:text-gray-600" />
            </div>
          )}
          <input ref={ref} className={`${baseStyles} ${stateStyles} ${paddingStyles}`} {...props} />
          {(hasError || showSuccess) && (
            <div className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2">
              {hasError ? (
                <AlertCircle className="h-5 w-5 text-red-500" />
              ) : (
                <CheckCircle className="h-5 w-5 text-green-500" />
              )}
            </div>
          )}
        </div>
        {(error || helperText) && (
          <p
            className={`text-sm ${
              hasError
                ? 'text-red-600 dark:text-red-400'
                : 'text-gray-500 dark:text-gray-400'
            }`}
          >
            {error || helperText}
          </p>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';
