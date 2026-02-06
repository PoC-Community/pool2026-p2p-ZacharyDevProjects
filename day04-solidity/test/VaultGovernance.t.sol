// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {PoolToken} from "../src/PoolToken.sol";
import {VaultGovernor} from "../src/VaultGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract VaultGovernanceTest is Test {
    PoolToken token;
    Vault vault;

    uint256 constant TOTAL_SUPPLY = 1_000_000 ether;
    address user = address(0x234);
    address governor = address(0x123);

    function setUp() public {
        token = new PoolToken(TOTAL_SUPPLY);
        vault = new Vault(token);
        vault.setGovernor(governor);
        token.transfer(user, 1000 ether);
        vm.startPrank(user);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 ether);
        vm.stopPrank();
    }

    function testSetWithdrawalFee() public {
        vm.prank(governor);
        vault.setWithdrawalFee(250);
        assertEq(vault.withdrawalFeeBps(), 250);
    }

    function testNonGovernorCannotSetFee () public {
        vm.prank(user);
        vm.expectRevert(Vault.OnlyGovernor.selector);
        vault.setWithdrawalFee(250);
    }

    function testFeeCannotExceedMax() public {
        vm.prank(governor);
        vm.expectRevert(Vault.FeeTooHigh.selector);
        vault.setWithdrawalFee(1500);
    }

    function testWithdrawalWithFee() public {
        vm.prank(governor);
        vault.setWithdrawalFee(250);
        uint256 balanceBefore = token.balanceOf(user);
        vm.prank(user);
        vault.withdrawAll();
        uint256 balanceAfter = token.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, 975 ether);
    }
}
