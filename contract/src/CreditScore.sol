// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CreditScore
 * @notice Manages user credit scores based on loan repayment history
 * @dev Scores range from 0-1000, affecting collateral requirements and loan terms
 */
contract CreditScore is Ownable {
    // Credit score data for each user
    struct UserScore {
        uint256 score; // Current score (0-1000)
        uint256 totalLoans; // Total loans taken
        uint256 completedLoans; // Successfully completed loans
        uint256 defaultedLoans; // Defaulted loans
        uint256 totalRepaid; // Total amount repaid (USDT, 6 decimals)
        uint256 lastUpdated; // Last score update timestamp
    }

    // State variables
    mapping(address => UserScore) public userScores;
    address public loanManager;

    // Constants
    uint256 public constant INITIAL_SCORE = 500; // Starting score for new users
    uint256 public constant MAX_SCORE = 1000;
    uint256 public constant MIN_SCORE = 0;
    uint256 public constant SCORE_INCREASE_PER_REPAYMENT = 10; // Points per successful repayment
    uint256 public constant SCORE_DECREASE_PER_DEFAULT = 100; // Points per default
    uint256 public constant BONUS_SCORE_THRESHOLD = 5; // Bonus after 5 successful loans
    uint256 public constant BONUS_SCORE_AMOUNT = 50;

    // Credit tiers with collateral multipliers
    uint256 public constant TIER_EXCELLENT = 800; // 110% collateral required
    uint256 public constant TIER_GOOD = 600; // 120% collateral required
    uint256 public constant TIER_FAIR = 400; // 140% collateral required
    uint256 public constant TIER_POOR = 200; // 160% collateral required
    // Below 200: 180% collateral required

    // Events
    event ScoreUpdated(address indexed user, uint256 oldScore, uint256 newScore, string reason);
    event LoanRecorded(address indexed user, uint256 loanAmount);
    event RepaymentRecorded(address indexed user, uint256 repaymentAmount);
    event DefaultRecorded(address indexed user, uint256 loanAmount);
    event LoanManagerUpdated(address indexed oldManager, address indexed newManager);

    // Errors
    error OnlyLoanManager();
    error InvalidScore();
    error InvalidAddress();

    /**
     * @notice Constructor
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @notice Set the loan manager address (only owner)
     * @param _loanManager The loan manager contract address
     */
    function setLoanManager(address _loanManager) external onlyOwner {
        if (_loanManager == address(0)) revert InvalidAddress();
        address oldManager = loanManager;
        loanManager = _loanManager;
        emit LoanManagerUpdated(oldManager, _loanManager);
    }

    /**
     * @notice Record a new loan for a user
     * @param user The borrower's address
     * @param loanAmount The loan amount (USDT, 6 decimals)
     */
    function recordLoan(address user, uint256 loanAmount) external {
        if (msg.sender != loanManager && msg.sender != owner()) revert OnlyLoanManager();

        UserScore storage userScore = userScores[user];

        // Initialize score for new users
        if (userScore.totalLoans == 0) {
            userScore.score = INITIAL_SCORE;
        }

        userScore.totalLoans++;
        userScore.lastUpdated = block.timestamp;

        emit LoanRecorded(user, loanAmount);
    }

    /**
     * @notice Record a successful loan repayment
     * @param user The borrower's address
     * @param repaymentAmount The amount repaid (USDT, 6 decimals)
     */
    function recordRepayment(address user, uint256 repaymentAmount) external {
        if (msg.sender != loanManager && msg.sender != owner()) revert OnlyLoanManager();

        UserScore storage userScore = userScores[user];
        uint256 oldScore = userScore.score;

        userScore.completedLoans++;
        userScore.totalRepaid += repaymentAmount;

        // Increase score for successful repayment
        uint256 newScore = oldScore + SCORE_INCREASE_PER_REPAYMENT;

        // Bonus for consistent repayment history
        if (userScore.completedLoans % BONUS_SCORE_THRESHOLD == 0) {
            newScore += BONUS_SCORE_AMOUNT;
        }

        // Cap at max score
        if (newScore > MAX_SCORE) {
            newScore = MAX_SCORE;
        }

        userScore.score = newScore;
        userScore.lastUpdated = block.timestamp;

        emit RepaymentRecorded(user, repaymentAmount);
        emit ScoreUpdated(user, oldScore, newScore, "Successful repayment");
    }

    /**
     * @notice Record a loan default
     * @param user The borrower's address
     * @param loanAmount The defaulted loan amount (USDT, 6 decimals)
     */
    function recordDefault(address user, uint256 loanAmount) external {
        if (msg.sender != loanManager && msg.sender != owner()) revert OnlyLoanManager();

        UserScore storage userScore = userScores[user];
        uint256 oldScore = userScore.score;

        userScore.defaultedLoans++;

        // Decrease score for default
        uint256 scoreDecrease = SCORE_DECREASE_PER_DEFAULT;
        uint256 newScore;

        if (oldScore > scoreDecrease) {
            newScore = oldScore - scoreDecrease;
        } else {
            newScore = MIN_SCORE;
        }

        userScore.score = newScore;
        userScore.lastUpdated = block.timestamp;

        emit DefaultRecorded(user, loanAmount);
        emit ScoreUpdated(user, oldScore, newScore, "Loan default");
    }

    /**
     * @notice Get user's credit score
     * @param user The user's address
     * @return The user's credit score (0-1000)
     */
    function getScore(address user) external view returns (uint256) {
        UserScore memory userScore = userScores[user];
        // Return initial score for new users
        return userScore.totalLoans == 0 ? INITIAL_SCORE : userScore.score;
    }

    /**
     * @notice Get user's full score data
     * @param user The user's address
     * @return score Current credit score
     * @return totalLoans Total loans taken
     * @return completedLoans Successfully completed loans
     * @return defaultedLoans Defaulted loans
     * @return totalRepaid Total amount repaid
     * @return successRate Success rate percentage (0-100)
     */
    function getUserData(address user)
        external
        view
        returns (
            uint256 score,
            uint256 totalLoans,
            uint256 completedLoans,
            uint256 defaultedLoans,
            uint256 totalRepaid,
            uint256 successRate
        )
    {
        UserScore memory userScore = userScores[user];
        score = userScore.totalLoans == 0 ? INITIAL_SCORE : userScore.score;
        totalLoans = userScore.totalLoans;
        completedLoans = userScore.completedLoans;
        defaultedLoans = userScore.defaultedLoans;
        totalRepaid = userScore.totalRepaid;

        // Calculate success rate
        if (totalLoans > 0) {
            successRate = (completedLoans * 100) / totalLoans;
        } else {
            successRate = 0;
        }
    }

    /**
     * @notice Get required collateral ratio based on credit score
     * @param user The user's address
     * @return collateralRatio The required collateral ratio (percentage)
     */
    function getRequiredCollateralRatio(address user) external view returns (uint256) {
        uint256 score = userScores[user].totalLoans == 0 ? INITIAL_SCORE : userScores[user].score;

        if (score >= TIER_EXCELLENT) {
            return 110; // Excellent: 110% collateral
        } else if (score >= TIER_GOOD) {
            return 120; // Good: 120% collateral
        } else if (score >= TIER_FAIR) {
            return 140; // Fair: 140% collateral
        } else if (score >= TIER_POOR) {
            return 160; // Poor: 160% collateral
        } else {
            return 180; // Very Poor: 180% collateral
        }
    }

    /**
     * @notice Get credit tier name based on score
     * @param user The user's address
     * @return tierName The tier name
     */
    function getCreditTier(address user) external view returns (string memory) {
        uint256 score = userScores[user].totalLoans == 0 ? INITIAL_SCORE : userScores[user].score;

        if (score >= TIER_EXCELLENT) {
            return "Excellent";
        } else if (score >= TIER_GOOD) {
            return "Good";
        } else if (score >= TIER_FAIR) {
            return "Fair";
        } else if (score >= TIER_POOR) {
            return "Poor";
        } else {
            return "Very Poor";
        }
    }

    /**
     * @notice Check if user qualifies for a loan amount based on history
     * @param user The user's address
     * @param loanAmount The requested loan amount
     * @return qualified Whether the user qualifies
     */
    function qualifiesForLoan(address user, uint256 loanAmount) external view returns (bool) {
        UserScore memory userScore = userScores[user];

        // New users qualify for small loans
        if (userScore.totalLoans == 0) {
            return loanAmount <= 5000e6; // Max 5000 USDT for new users
        }

        // Users with defaults have restrictions
        if (userScore.defaultedLoans > 0) {
            uint256 defaultRate = (userScore.defaultedLoans * 100) / userScore.totalLoans;
            if (defaultRate > 20) {
                // More than 20% default rate
                return false;
            }
        }

        // Loan amount scales with score and history
        uint256 maxLoan;
        if (userScore.score >= TIER_EXCELLENT) {
            maxLoan = 100000e6; // 100k USDT
        } else if (userScore.score >= TIER_GOOD) {
            maxLoan = 50000e6; // 50k USDT
        } else if (userScore.score >= TIER_FAIR) {
            maxLoan = 20000e6; // 20k USDT
        } else if (userScore.score >= TIER_POOR) {
            maxLoan = 10000e6; // 10k USDT
        } else {
            maxLoan = 5000e6; // 5k USDT
        }

        return loanAmount <= maxLoan;
    }
}
