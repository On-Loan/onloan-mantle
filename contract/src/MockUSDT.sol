// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockUSDT
 * @notice ERC20 token for testing OnLoan protocol on Mantle testnet
 * @dev 6 decimals to match real USDT, mintable by owner
 */
contract MockUSDT is ERC20, Ownable {
    uint8 private constant DECIMALS = 6;

    constructor() ERC20("Mock USDT", "USDT") Ownable(msg.sender) {
        // Mint initial supply to deployer (1 million USDT)
        _mint(msg.sender, 1_000_000 * 10 ** DECIMALS);
    }

    /**
     * @notice Returns 6 decimals to match real USDT
     */
    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    /**
     * @notice Mint tokens to specified address
     * @param to Recipient address
     * @param amount Amount to mint (with 6 decimals)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "MockUSDT: mint to zero address");
        require(amount > 0, "MockUSDT: mint amount zero");
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from caller
     * @param amount Amount to burn (with 6 decimals)
     */
    function burn(uint256 amount) external {
        require(amount > 0, "MockUSDT: burn amount zero");
        _burn(msg.sender, amount);
    }
}
