pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/SmartContract.sol";

//Step 0.06 - Foundry Tests

contract SmartContractHelper is SmartContract {
    function getAreYouABadPerson() public view returns (bool) {
        return _areYouABadPerson; 
    }
}

contract SmartContractTester is Test {
    SmartContractHelper got;

    function setUp() public {
        got = new SmartContractHelper();
    }

    function testSomething() public view {
        assertEq(got.getHalfAnswerOfLife(), 21);
    }
    function testSomething2() public view {
        assertEq(got.getAreYouABadPerson(), false);
    }
    function testMyInformations() public view {
        (string memory firstname, string memory lastName, uint8 age, string memory city, SmartContract.roleEnum role) = got.myInformations();
        assertEq(firstname, "Zachary");
        assertEq(lastName, "Joriot");
        assertEq(age, 20);
        assertEq(city, "Paris");
        assertEq(uint8(role), 0);
    }
}