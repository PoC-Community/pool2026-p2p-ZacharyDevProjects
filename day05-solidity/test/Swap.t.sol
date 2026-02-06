// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Swap} from "../src/Swap.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

// Simple ERC-20 for testing
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract SwapTest is Test {
    Swap public swap;
    MockPriceFeed public mockFeed;
    MockToken public mockToken;

    function setUp() public {
        mockFeed = new MockPriceFeed();
        mockFeed.setPrice(300000000000); // $3000 with 8 decimals

        mockToken = new MockToken();

        swap = new Swap(
            address(mockFeed),
            address(mockToken),
            18,
            1e18, // token price = $1
            3600 // stale threshold = 1 hour
        );

        mockToken.transfer(address(swap), 100_000 ether);
    }

    function testGetCurrentPrice() public view {
        (uint256 price, bool isStale, ) = swap.getCurrentPrice();
        uint256 exceptprice = 3000 * 1e18;
        assertEq(price, exceptprice);
        assertEq(isStale, false);
    }

    function testSwapSuccess() public {
        address user = address(0x1234);
        vm.deal(user, 10 ether);

        vm.prank(user);
        uint256 tokensOut = swap.swap{value: 1 ether}();

        // 1 ETH × $3000 ÷ $1 = 3000 tokens
        assertEq(tokensOut, 3000 ether);
        assertEq(mockToken.balanceOf(user), 3000 ether);
    }

    function testSwapZeroValue() public {
        vm.expectRevert();
        swap.swap{value: 0}();
    }

    function testPreviewSwap() public view {
        (uint256 tokensOut, ) = swap.previewSwap(1 ether);
        assertEq(tokensOut, 3000 ether);
    }

    function testGetMaxSwappableETH() public view {
        uint256 maxEth = swap.getMaxSwappableETH();
        // 100,000 tokens ÷ $3000 per ETH ≈ 33.33 ETH
        assertApproxEqAbs(maxEth, 33.333333333333333333 ether, 0.001 ether);
    }
}
