// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {PoolToken} from "../src/PoolToken.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultHelper is Vault {
    constructor(IERC20 _asset) Vault(_asset) {}

    function convertToShares(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    function convertToAssets(uint256 assets) external view returns (uint256) {
        return _convertToAssets(assets);
    }

    function setTotalShares(uint256 _shares) external {
        totalShares = _shares;
    }

    function setSharesOf(address user, uint256 shares) external {
        sharesOf[user] = shares;
    }
}

contract VaultTester is Test {
    VaultHelper vault;
    PoolToken fakeToken;

    function setUp() public {
        fakeToken = new PoolToken(1000);
        vault = new VaultHelper(fakeToken);
        fakeToken.transfer(address(0x123), 200);
        vm.prank(address(0x123));
        fakeToken.approve(address(vault), 200);
        vm.prank(address(0x123));
        vault.deposit(200);
    }

    function testConvertToShares() public {
        uint256 assets = 100;

        uint256 shares = vault.convertToShares(assets);

        assertEq(shares, 100);
    }

    function testconvertToAssets() public {
        uint256 shares = 100;

        uint256 assets = vault.convertToAssets(shares);

        assertEq(assets, 100);
    }

    function testConvertToSharesIfTotalShareIs0() public {
        vault.setTotalShares(0);
        uint256 assets = 100;

        uint256 shares = vault.convertToShares(assets);

        assertEq(shares, assets);
    }

    function testconvertToAssetsIfTotalShareIs0() public {
        vault.setTotalShares(0);
        uint256 shares = 100;

        uint256 assets = vault.convertToAssets(shares);

        assertEq(assets, 0);
    }

    function testpreviewdeposit() public {
        uint256 share = vault.previewDeposit(200);
        assertEq(share, 200);
    }

    function testpreviewwithdraw() public {
        uint256 assets = vault.previewWithdraw(200);
        assertEq(assets, 200);
    }


    function testdeposit() public {
        address user = address(0x010);
        fakeToken.transfer(user, 200);
        vm.startPrank(user);
        fakeToken.approve(address(vault), 200);
        uint256 shares = vault.deposit(200);
        vm.stopPrank();
        assertEq(shares, 200);
    }

    function testwithdraw() public {
        address user = address(0x010);
        vault.setSharesOf(user, 200);
        vm.prank(user);
        uint256 assets = vault.withdraw(100);
        assertEq(assets, 100);
    }

    function testreward() public {
        fakeToken.approve(address(vault), 50);
        vault.addReward(50);
        assertEq(vault.totalAssets(), 250);
        vault.currentRatio();
        vault.assetsOf(address(0x123));
        vm.prank(address(0x123));
        uint256 assets = vault.withdrawAll();
        assertEq(assets, 250);
        
    }
}
