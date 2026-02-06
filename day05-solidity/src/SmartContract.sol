// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/local/src/data-feeds/interfaces/AggregatorV3Interface.sol";

contract SmartContract {
    AggregatorV3Interface public immutable PRICE_FEED;

    constructor(AggregatorV3Interface _priceFeed) {
        PRICE_FEED = _priceFeed;
    }
    function getLatestPrice() public view returns (int256) {
        (, int256 answer, , ,) = PRICE_FEED.latestRoundData();
        return answer;
    }
    function getDecimals() public view returns (uint8) {
        return PRICE_FEED.decimals(); 
    }
    function getPriceIn18Decimals() public view returns (uint256) {
        int256 answer = getLatestPrice();
        uint8 decimals = getDecimals();
        return uint256(answer) * 10 ** (18 - decimals);
    }
}
