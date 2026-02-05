// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Vault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public immutable ASSET;

    uint256 public totalShares;

    mapping(address => uint256) public sharesOf;

    event Deposit (address indexed user, uint256 assets, uint256 shares);
    event Withdraw (address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 amount);

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    constructor(IERC20 _asset) Ownable(msg.sender) {
        ASSET = _asset;
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        if (totalShares == 0) {
            return assets;
        }
        return (assets * totalShares) / ASSET.balanceOf(address(this));
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        if (totalShares == 0) {
            return 0;
        }
        return (shares * ASSET.balanceOf(address(this))) / totalShares;
        
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        if (assets <= 0) {
            revert ZeroAmount();
        }
        uint256 mintedShares = _convertToShares(assets);
        if (mintedShares <= 0) {
            revert ZeroShares();
        }
        sharesOf[msg.sender] += mintedShares;
        totalShares += mintedShares;
        ASSET.safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, assets, mintedShares);

        return mintedShares;
    }

    function withdraw (uint256 shares) public nonReentrant returns (uint256 assets) {
        if (shares <= 0) {
            revert ZeroShares();
        }
        if (sharesOf[msg.sender] < shares) {
            revert InsufficientShares();
        }
        uint256 assetAmount = _convertToAssets(shares);
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        ASSET.safeTransfer(msg.sender, assetAmount);
        emit Withdraw(msg.sender, assetAmount, shares);

        return assetAmount;

    }

    function withdrawAll() public returns (uint256 assets) {
        return withdraw(sharesOf[msg.sender]);
    }

    function previewDeposit(uint256 assets) external view returns (uint256 shares) {
        return _convertToShares(assets);
    }

    function previewWithdraw(uint256 shares) external view returns (uint256 assets) {
        return _convertToAssets(shares);
    }

    function totalAssets() public view returns (uint256) {
        return ASSET.balanceOf(address(this));
    }

    function currentRatio() external view returns (uint256) {
        if (totalShares == 0) {
            return 1e18;
        }
        return (ASSET.balanceOf(address(this)) * 1e18) / totalShares;
    }

    function assetsOf(address user) external view returns (uint256) {
        return _convertToAssets(sharesOf[user]);
    }

    function addReward(uint256 amount) external onlyOwner nonReentrant {
        if (amount <= 0) {
            revert ZeroAmount();
        }
        if (totalShares <= 0) {
            revert InsufficientShares();
        }
        ASSET.safeTransferFrom(msg.sender, address(this), amount);

        emit RewardAdded(amount);
    }
}