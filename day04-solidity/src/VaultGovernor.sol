// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract VaultGovernor is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    uint256 private immutable _VOTING_DELAY;
    uint256 private immutable _VOTING_PERIOD;

    constructor(IVotes token_,uint256 votingDelay_,uint256 votingPeriod_,uint256 quorumPercentage_)Governor("VaultGovernor")GovernorVotes(token_)GovernorVotesQuorumFraction(quorumPercentage_){
        _VOTING_DELAY = votingDelay_;
        _VOTING_PERIOD = votingPeriod_;
    }

    function votingDelay() public view override returns (uint256) {
        return _VOTING_DELAY;
    }

    function votingPeriod() public view override returns (uint256) {
        return _VOTING_PERIOD;
    }

    function quorum(uint256 blockNumber) public view override(Governor, GovernorVotesQuorumFraction) returns (uint256) {
        return super.quorum(blockNumber);
    }
}
