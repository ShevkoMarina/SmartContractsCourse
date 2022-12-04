// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ProxyRPS {

    modifier onlyRegistred() {
        require(players[msg.sender].exists, "You are not registred");
        _;
    }
    
    enum Decision {
        UNKNOWN,
        PAPER,
        ROCK,
        SCISSORS
    }

    enum GameState {
        UNKNOWN,
        DRAW,
        WIN,
        LOSE
    }
    
   address public owner;

    struct Player {
        string name;
        uint256 win;
        uint256 loss;
        uint256 draw;
        bool exists;
    }

    uint256 public playersCounter;
    address[] public arrPlayers;

    mapping(address => Player) public players;

    struct PlayerDecision {
        bool desided;
        GameState gameState;
        Decision desidion;
    }

    struct Game {
        bool exists;
        bool complete;
        mapping(address => PlayerDecision) playerDecisions;
        address p1;
        address p2;
    }

    struct GameResult {
        address winner;
        address loser;
        bool draw;
        bool gameEnded;
    }

    mapping(uint256 => Game) public games;
    uint256 gamesCount;
    address gameContract;

    event NewRegistred(address indexed walletAddress, string name);

    event InvetedToGame(address indexed walletAddress, uint256 gameId);

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
