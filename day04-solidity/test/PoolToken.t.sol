// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTester is Test {
    PoolToken token;
    address alice = address(0x1);
    address bob   = address(0x2);

    function setUp() public {
        token = new PoolToken(1000);
        token.transfer(alice, 400);
    }

    function testInitialVotingPowerIsZero() public {
        uint256 votes = token.getVotes(msg.sender);
        assertEq(votes, 0);
    }

    function testDelegateToSelf() public {
        token.delegate(msg.sender);
        vm.roll(block.number + 1);
        uint256 votes = token.getVotes(msg.sender);
        assertEq(votes, 600);
    }

    function testDelegateToOther() public {
        uint256 votes;
        vm.prank(alice);
        token.delegate(bob);
        vm.roll(block.number + 1);
        votes = token.getVotes(alice);
        assertEq(votes, 0);
        votes = token.getVotes(bob);
        assertEq(votes, 400);
    }

    function testGetPastVotes() public {
        uint256 startBlock = block.number;
        token.delegate(address(this));
        vm.roll(startBlock + 1);
        uint256 votes = token.getPastVotes(address(this), startBlock-1);
        assertEq(votes, 0);
    }
}