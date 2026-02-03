// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// src/interfaces/ISmartContract.sol

interface ISmartContract {

    event BalanceUpdated(address indexed user, uint256 newBalance);

    error InsufficientBalance(uint256 available, uint256 requested);

    function getHalfAnswerOfLife() external view returns (uint256);

    function getPoCIsWhat() external view returns (string memory);

    function getMyBalance() external view returns (uint256);

    function addToBalance() external payable;

    function withdrawFromBalance(uint256 _amount) external;
}

// src/SmartContract.sol
//Step 0.01 - Basic Structure

contract SmartContract is ISmartContract {
    //Step 0.02 & 0.03 - Variables and Visibility

    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public poCIsWhat = "PoC is good, PoC is life.";
    bool internal _areYouABadPerson = false;
    int256 private _youAreACheater = -42;
    address private owner;

    //Step 0.04 - Advanced Types

    bytes32 public whoIsTheBest;
    mapping(string => uint256) public myGrades;

    string[5] public myPhoneNumber;

    enum roleEnum {
        STUDENT,
        TEACHER
    }

    struct Informations {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        roleEnum role;
    }

    Informations public myInformations =
        Informations({
            firstName: "Zachary",
            lastName: "Joriot",
            age: 20,
            city: "Paris",
            role: roleEnum.STUDENT
        });

    //Step 0.05 - Functions

    function getHalfAnswerOfLife() public view returns (uint256) {
        return halfAnswerOfLife;
    }

    function _getMyEthereumContractAddress() internal view returns (address) {
        return myEthereumContractAddress;
    }

    function getPoCIsWhat() external view returns (string memory) {
        return poCIsWhat;
    }

    function _setAreYouABadPerson(bool _value) internal {
        if (_value) {
            _areYouABadPerson = true;
        }
    }

    //Step 0.07 - Data Location

    function editMyCity(string calldata _newCity) public {
        myInformations.city = _newCity;
    }

    function getMyFullName() public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    myInformations.firstName,
                    " ",
                    myInformations.lastName
                )
            );
    }

    //Step 0.08 - Modifiers

    constructor() {
        owner = msg.sender;
    }

    function _checkOwner() internal view {
        require(msg.sender == owner, "Not the owner");
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function sensitiveAction() public onlyOwner {
        halfAnswerOfLife += 21;
    }

    //Step 0.09 - Hashing

    function hashMyMessage(
        string calldata _message
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    //Step 0.10 - ETH Management

    mapping(address => uint256) public balances;

    //Step 0.11 - Events

    //Step 0.12 - Custom Errors

    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function addToBalance() public payable {
        balances[msg.sender] += msg.value;

        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }

    function withdrawFromBalance(uint256 _amount) public {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance(balances[msg.sender], _amount);
        }

        balances[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }
}

