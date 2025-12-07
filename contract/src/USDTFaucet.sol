// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title USDTFaucet
 * @notice Distributes test USDT to users every 24 hours
 * @dev Time-based restrictions prevent abuse
 */
contract USDTFaucet is Ownable, ReentrancyGuard {
    IERC20 public immutable usdtToken;
    
    // 1000 USDT per claim (6 decimals)
    uint256 public constant CLAIM_AMOUNT = 1000 * 10 ** 6;
    
    // 24 hours between claims
    uint256 public constant CLAIM_INTERVAL = 24 hours;
    
    // Track last claim time per address
    mapping(address => uint256) public lastClaimTime;
    
    // Total claims tracking
    uint256 public totalClaims;
    uint256 public totalDistributed;

    // Events
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event FaucetRefilled(address indexed funder, uint256 amount);

    constructor(address _usdtToken) Ownable(msg.sender) {
        require(_usdtToken != address(0), "USDTFaucet: zero address");
        usdtToken = IERC20(_usdtToken);
    }

    /**
     * @notice Claim 1000 USDT (callable once every 24 hours)
     * @return success True if claim successful
     */
    function claimTokens() external nonReentrant returns (bool) {
        require(canClaim(msg.sender), "USDTFaucet: claim too soon");
        require(
            usdtToken.balanceOf(address(this)) >= CLAIM_AMOUNT,
            "USDTFaucet: insufficient balance"
        );

        // Update state before transfer
        lastClaimTime[msg.sender] = block.timestamp;
        totalClaims++;
        totalDistributed += CLAIM_AMOUNT;

        // Transfer tokens
        require(
            usdtToken.transfer(msg.sender, CLAIM_AMOUNT),
            "USDTFaucet: transfer failed"
        );

        emit TokensClaimed(msg.sender, CLAIM_AMOUNT, block.timestamp);
        return true;
    }

    /**
     * @notice Check if user can claim tokens
     * @param user Address to check
     * @return eligible True if user can claim
     */
    function canClaim(address user) public view returns (bool) {
        // First-time claimers can claim immediately
        if (lastClaimTime[user] == 0) {
            return true;
        }
        return block.timestamp >= lastClaimTime[user] + CLAIM_INTERVAL;
    }

    /**
     * @notice Get time until next claim
     * @param user Address to check
     * @return timeRemaining Seconds until next claim (0 if eligible now)
     */
    function getNextClaimTime(address user) external view returns (uint256) {
        // First-time claimers can claim immediately
        if (lastClaimTime[user] == 0) {
            return 0;
        }
        uint256 nextClaimTime = lastClaimTime[user] + CLAIM_INTERVAL;
        if (block.timestamp >= nextClaimTime) {
            return 0;
        }
        return nextClaimTime - block.timestamp;
    }

    /**
     * @notice Get claim amount
     * @return amount USDT amount per claim
     */
    function getClaimAmount() external pure returns (uint256) {
        return CLAIM_AMOUNT;
    }

    /**
     * @notice Refill faucet with USDT (owner or anyone can fund)
     * @param amount Amount to add to faucet
     */
    function refillFaucet(uint256 amount) external {
        require(amount > 0, "USDTFaucet: zero amount");
        require(
            usdtToken.transferFrom(msg.sender, address(this), amount),
            "USDTFaucet: transfer failed"
        );
        emit FaucetRefilled(msg.sender, amount);
    }

    /**
     * @notice Emergency withdraw (owner only)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "USDTFaucet: zero amount");
        require(
            usdtToken.transfer(owner(), amount),
            "USDTFaucet: transfer failed"
        );
    }

    /**
     * @notice Get faucet balance
     * @return balance Current USDT balance
     */
    function getFaucetBalance() external view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }
}
