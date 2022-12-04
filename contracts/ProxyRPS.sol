// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ProxyRPS {
    
    struct Player {
        string name;
        uint256 win;
        uint256 loss;
        uint256 draw;
        bool exists;
    }

    int256 playersCounter;
    address[] public arrPlayers;
    mapping(address => Player) public players;

    address gameContract;

    constructor (address _contract) public {
        gameContract = _contract;
    }

    function delegateCallSignIn(string memory name) public payable {
      
        (bool success, bytes memory data) = gameContract.delegatecall(
            abi.encodeWithSignature("signIn(string)", name)
        );

        require(success, "Error");
    }

     function callSignIn(string memory name) public payable {
    
        (bool success, bytes memory data) = gameContract.call(
             abi.encodeWithSignature("signIn(string)", name)
        );

        require(success, "Error");
    }
}
