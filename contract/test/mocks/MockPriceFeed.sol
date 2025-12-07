// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPriceOracle} from "../../src/interfaces/IPriceOracle.sol";

/**
 * @title MockPriceFeed
 * @notice Mock price feed for testing collateral and liquidation scenarios
 * @dev Simulates Chainlink price oracle behavior with configurable price and timestamp
 */
contract MockPriceFeed is IPriceOracle {
    int256 private _price;
    uint8 private _decimals;
    uint256 private _updatedAt;
    string private _description;

    /**
     * @notice Constructor to initialize the mock price feed
     * @param initialPrice The initial price value
     * @param initialDecimals The number of decimals (typically 8 for USD feeds)
     * @param feedDescription The description of the price feed
     */
    constructor(int256 initialPrice, uint8 initialDecimals, string memory feedDescription) {
        _price = initialPrice;
        _decimals = initialDecimals;
        _updatedAt = block.timestamp;
        _description = feedDescription;
    }

    /**
     * @notice Set a new price (for testing price changes)
     * @param newPrice The new price to set
     */
    function setPrice(int256 newPrice) external {
        _price = newPrice;
        _updatedAt = block.timestamp;
    }

    /**
     * @notice Set the last updated timestamp (for testing staleness)
     * @param timestamp The timestamp to set
     */
    function setUpdatedAt(uint256 timestamp) external {
        _updatedAt = timestamp;
    }

    /**
     * @notice Set the decimals (for testing different price formats)
     * @param newDecimals The new decimals value
     */
    function setDecimals(uint8 newDecimals) external {
        _decimals = newDecimals;
    }

    /**
     * @inheritdoc IPriceOracle
     */
    function getLatestPrice() external view override returns (int256 price, uint8 decimalsValue, uint256 updatedAt) {
        return (_price, _decimals, _updatedAt);
    }

    /**
     * @inheritdoc IPriceOracle
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @inheritdoc IPriceOracle
     */
    function description() external view override returns (string memory) {
        return _description;
    }

    /**
     * @notice Get the current price directly (convenience function)
     * @return The current price
     */
    function getPrice() external view returns (int256) {
        return _price;
    }
}
