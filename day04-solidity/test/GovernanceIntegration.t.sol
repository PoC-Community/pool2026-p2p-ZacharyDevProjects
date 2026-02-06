// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VaultGovernor} from "../src/VaultGovernor.sol";
import {PoolToken} from "../src/PoolToken.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {Vault} from "../src/Vault.sol";

contract GovernanceIntegrationTester is Test {
    PoolToken token;
    Vault vault;
    VaultGovernor governor;

    uint256 constant TOTAL_SUPPLY = 1_000_000 ether;
    uint256 constant VOTING_DELAY = 1;
    uint256 constant VOTING_PERIOD = 45818;
    uint256 constant QUORUM_PERCENT = 4;
    address user = address(0x234);
    address voter = address(0x123);

    function setUp() public {
        token = new PoolToken(TOTAL_SUPPLY);
        governor = new VaultGovernor(
            IVotes(address(token)),
            VOTING_DELAY,
            VOTING_PERIOD,
            QUORUM_PERCENT
        );
        vault = new Vault(token);
        vault.setGovernor(address(governor));
    }

    function testFullGovernanceWorkflow() public {
        token.transfer(user, 50000 ether);
        vm.prank(user);
        token.delegate(user);
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(vault);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(
            Vault.setWithdrawalFee.selector,
            250
        );
        string memory description = "Set withdrawal fee to 2.5%";

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.startPrank(user);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(50000 ether);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        vm.roll(block.number + governor.votingPeriod() + 1);

        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(description))
        );

        assertEq(vault.withdrawalFeeBps(), 250);
    }

    function testCannotVoteTwice() public {
        token.transfer(user, 50000 ether);
        vm.prank(user);
        token.delegate(user);
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(vault);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(
            Vault.setWithdrawalFee.selector,
            250
        );
        string memory description = "Set withdrawal fee to 2.5%";

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(user);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user);
        vault.deposit(50000 ether);
        vm.prank(user);
        governor.castVote(proposalId, 1);
        vm.prank(user);
        vm.expectRevert();
        governor.castVote(proposalId, 1);
    }

    function testProposalFailsWithoutQuorum() public {
        token.transfer(user, 30000 ether);
        vm.prank(user);
        token.delegate(user);
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(vault);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(
            Vault.setWithdrawalFee.selector,
            250
        );
        string memory description = "Set withdrawal fee to 2.5%";

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            description
        );

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.startPrank(user);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(30000 ether);
        governor.castVote(proposalId, 1);
        vm.stopPrank();

        vm.roll(block.number + governor.votingPeriod() + 1);

        uint256 state = uint256(governor.state(proposalId));
        assertEq(state, 3);
    }
}
