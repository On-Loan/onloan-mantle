// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPriceOracle
 * @notice Interface for price oracle integration (Chainlink-compatible)
 * @dev Provides standardized price feed access with staleness checks
 */
interface IPriceOracle {
    /**
     * @notice Get the latest price from the oracle
     * @return price The latest price (scaled by decimals)
     * @return decimals The number of decimals in the price
     * @return updatedAt The timestamp of the last price update
     */
    function getLatestPrice() external view returns (int256 price, uint8 decimals, uint256 updatedAt);

    /**
     * @notice Get the price feed decimals
     * @return The number of decimals
     */
    function decimals() external view returns (uint8);

    /**
     * @notice Get the description of the price feed
     * @return The price feed description (e.g., "ETH / USD")
     */
    function description() external view returns (string memory);
}
