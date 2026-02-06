// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VaultGovernor} from "../src/VaultGovernor.sol";
import {PoolToken} from "../src/PoolToken.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";



contract VaultGovernorTester is Test {
    PoolToken token;
    VaultGovernor governor;

    uint256 constant TOTAL_SUPPLY = 1_000_000 ether;
    uint256 constant VOTING_DELAY = 1;
    uint256 constant VOTING_PERIOD = 45818;
    uint256 constant QUORUM_PERCENT = 4;

    function setUp() public {
        token = new PoolToken(TOTAL_SUPPLY);
        governor = new VaultGovernor(
            IVotes(address(token)),
            VOTING_DELAY,
            VOTING_PERIOD,
            QUORUM_PERCENT
        );
    }

    function testGovernorParameters() public {
        assertEq(governor.votingDelay(), VOTING_DELAY);
        assertEq(governor.votingPeriod(), VOTING_PERIOD);
        assertEq(governor.name(), "VaultGovernor");
    }

    function testQuorumCalculation() public {
        token.delegate(address(this));
        vm.roll(block.number + 1);
        uint256 blockNumber = block.number;
        uint256 quorum = governor.quorum(blockNumber-1);
        assertEq(quorum, 40_000 ether);
    }

    function testCreateProposal() public {
        token.delegate(address(this));
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values= new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(this);
        values[0] = 0;
        calldatas[0] = bytes("");

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            "Test proposal"
        );

        assertTrue(proposalId != 0);
    }
}
