// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISmartContract {

    event BalanceUpdated(address indexed user, uint256 newBalance);

    error InsufficientBalance(uint256 available, uint256 requested);

    function getHalfAnswerOfLife() external view returns (uint256);

    function getPoCIsWhat() external view returns (string memory);

    function getMyBalance() external view returns (uint256);

    function addToBalance() external payable;

    function withdrawFromBalance(uint256 _amount) external;
}
