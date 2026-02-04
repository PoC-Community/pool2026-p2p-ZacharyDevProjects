// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/ProfileSystem.sol";

//Step 0.06 - Foundry Tests

contract HelperProfileSystem is ProfileSystem {

}

contract ProfileSystemTester is Test {
    HelperProfileSystem got;

    function setUp() public {
        got = new HelperProfileSystem();
    }

    function testCreateProfile() public {
        got.createProfile("test");

        (string memory username, uint256 level, ProfileSystem.Role role, ) = got
            .profiles(address(this));

        assertEq(username, "test");
        assertEq(level, 1);
        assertEq(uint256(role), uint256(ProfileSystem.Role.USER));
    }

    function testLevelUp() public {
        got.createProfile("test");
        got.levelUp();

        (, uint256 level, , ) = got.profiles(address(this));
        assertEq(level, 2);
    }

    function testCannotCreateProfileTwice() public {
        got.createProfile("PremierNom");
        vm.expectRevert(ProfileSystem.UserAlreadyExists.selector);
        got.createProfile("DeuxiemeNom");
    }
}
