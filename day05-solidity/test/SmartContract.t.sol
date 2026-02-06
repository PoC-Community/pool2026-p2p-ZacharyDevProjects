// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/local/src/data-feeds/interfaces/AggregatorV3Interface.sol";
import {Test} from "forge-std/Test.sol";

contract SmartContractTester is Test {
    AggregatorV3Interface priceFeed;

    function setUp() public {
        priceFeed = AggregatorV3Interface(address(0x123));
    }
}
