import { useState } from 'react';
import {
  Button,
  Card,
  Input,
  Modal,
  Toast,
  ToastContainer,
  Spinner,
} from '../components/ui';
import {
  Wallet,
  TrendingUp,
  DollarSign,
  Users,
  Mail,
  Lock,
  ArrowRight,
  Download,
} from 'lucide-react';

export const ComponentTest = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [showToast, setShowToast] = useState<string | null>(null);
  const [inputValue, setInputValue] = useState('');
  const [inputError, setInputError] = useState('');

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setInputValue(value);
    if (value.length < 3 && value.length > 0) {
      setInputError('Must be at least 3 characters');
    } else {
      setInputError('');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950 p-8">
      <div className="mx-auto max-w-6xl space-y-12">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-100">
            UI Component Library
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            OnLoan design system showcase
          </p>
        </div>

        {/* Buttons */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Buttons
          </h2>
          <div className="space-y-6">
            <div className="flex flex-wrap gap-4">
              <Button variant="primary">Primary Button</Button>
              <Button variant="secondary">Secondary Button</Button>
              <Button variant="ghost">Ghost Button</Button>
              <Button variant="icon">
                <Wallet className="h-5 w-5" />
              </Button>
            </div>

            <div className="flex flex-wrap gap-4">
              <Button variant="primary" size="sm">
                Small
              </Button>
              <Button variant="primary" size="md">
                Medium
              </Button>
              <Button variant="primary" size="lg">
                Large
              </Button>
            </div>

            <div className="flex flex-wrap gap-4">
              <Button variant="primary" loading>
                Loading
              </Button>
              <Button variant="primary" disabled>
                Disabled
              </Button>
              <Button variant="primary" fullWidth>
                Full Width Button
              </Button>
            </div>
          </div>
        </section>

        {/* Cards */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">Cards</h2>
          <div className="grid gap-6 md:grid-cols-3">
            <Card variant="standard" title="Standard Card" icon={TrendingUp}>
              This is a standard card with a border and icon.
            </Card>

            <Card variant="elevated" title="Elevated Card" icon={DollarSign}>
              This is an elevated card with shadow effects and hover animation.
            </Card>

            <Card variant="stat" title="Total Users" icon={Users}>
              1,234
            </Card>
          </div>
        </section>

        {/* Inputs */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Inputs
          </h2>
          <div className="grid gap-6 md:grid-cols-2">
            <Input label="Email" type="email" placeholder="Enter your email" icon={Mail} />

            <Input
              label="Password"
              type="password"
              placeholder="Enter your password"
              icon={Lock}
            />

            <Input
              label="Validated Input"
              placeholder="Type at least 3 characters"
              value={inputValue}
              onChange={handleInputChange}
              error={inputError}
              success={inputValue.length >= 3}
            />

            <Input
              label="Disabled Input"
              placeholder="This is disabled"
              disabled
              helperText="This field is not editable"
            />
          </div>
        </section>

        {/* Modal */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Modal
          </h2>
          <Button variant="primary" onClick={() => setIsModalOpen(true)}>
            Open Modal
          </Button>

          <Modal
            isOpen={isModalOpen}
            onClose={() => setIsModalOpen(false)}
            title="Example Modal"
            footer={
              <div className="flex justify-end gap-3">
                <Button variant="ghost" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </Button>
                <Button variant="primary" onClick={() => setIsModalOpen(false)}>
                  Confirm
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </div>
            }
          >
            <p className="text-gray-700 dark:text-gray-300">
              This is an example modal with header, body, and footer sections. It includes
              animations, backdrop blur, and can be closed with the X button, ESC key, or by
              clicking outside.
            </p>
          </Modal>
        </section>

        {/* Toasts */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Toasts
          </h2>
          <div className="flex flex-wrap gap-4">
            <Button variant="primary" onClick={() => setShowToast('success')}>
              Success Toast
            </Button>
            <Button variant="primary" onClick={() => setShowToast('error')}>
              Error Toast
            </Button>
            <Button variant="primary" onClick={() => setShowToast('warning')}>
              Warning Toast
            </Button>
            <Button variant="primary" onClick={() => setShowToast('info')}>
              Info Toast
            </Button>
          </div>
        </section>

        {/* Spinners */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Spinners
          </h2>
          <div className="flex items-center gap-8">
            <div className="text-center">
              <Spinner size="sm" />
              <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">Small</p>
            </div>
            <div className="text-center">
              <Spinner size="md" />
              <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">Medium</p>
            </div>
            <div className="text-center">
              <Spinner size="lg" />
              <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">Large</p>
            </div>
          </div>
        </section>

        {/* Button with Icon Examples */}
        <section>
          <h2 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">
            Buttons with Icons
          </h2>
          <div className="flex flex-wrap gap-4">
            <Button variant="primary">
              <Download className="h-4 w-4" />
              Download
            </Button>
            <Button variant="secondary">
              <Wallet className="h-4 w-4" />
              Connect Wallet
            </Button>
            <Button variant="ghost">
              View Details
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>
        </section>
      </div>

      {/* Toast Container */}
      <ToastContainer>
        {showToast === 'success' && (
          <Toast
            type="success"
            message="Operation completed successfully!"
            isVisible={true}
            onClose={() => setShowToast(null)}
          />
        )}
        {showToast === 'error' && (
          <Toast
            type="error"
            message="An error occurred. Please try again."
            isVisible={true}
            onClose={() => setShowToast(null)}
          />
        )}
        {showToast === 'warning' && (
          <Toast
            type="warning"
            message="Please review your inputs before proceeding."
            isVisible={true}
            onClose={() => setShowToast(null)}
          />
        )}
        {showToast === 'info' && (
          <Toast
            type="info"
            message="Here's some helpful information for you."
            isVisible={true}
            onClose={() => setShowToast(null)}
          />
        )}
      </ToastContainer>
    </div>
  );
};
