// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PaperRockScissors {
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

    // Возвращаем результат для первого
    function compareDesidions(Decision d1, Decision d2)
        public
        pure
        returns (GameState)
    {
        if (d1 == Decision.UNKNOWN || d2 == Decision.UNKNOWN) {
            return GameState.UNKNOWN;
        }

        if (d1 == d2) {
            return GameState.DRAW;
        }

        if ((d1 == Decision.PAPER && d2 == Decision.ROCK) ||
            (d1 == Decision.ROCK && d2 == Decision.SCISSORS) ||
            (d1 == Decision.SCISSORS && d2 == Decision.PAPER)) {
            return GameState.WIN;
        }

        return GameState.LOSE;
    }

    address public owner;

    struct Player {
        string name;
        uint256 win;
        uint256 loss;
        uint256 draw;
        bool exists;
    }

    uint256 playersCounter;
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

    function getPlayer(address id) public view returns (Player memory) {
        Player storage p = players[id];
        require(p.exists, "player not exits");
        return p;
    }

    function getGame(uint64 id) public view returns (GameResult memory) {
        Game storage game = games[id];
        require(game.exists, "Game not exists");
        GameResult memory gameResult;

        if (game.complete) {
            gameResult.gameEnded = true;
            if (game.playerDecisions[game.p1].gameState == GameState.WIN) {
                gameResult.winner = game.p1;
                gameResult.loser = game.p2;
            } else if (
                game.playerDecisions[game.p1].gameState == GameState.LOSE
            ) {
                gameResult.winner = game.p2;
                gameResult.loser = game.p1;
            } else {
                gameResult.draw = true;
            }
        }

        return gameResult;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyRegistred() {
        require(players[msg.sender].exists, "You are not registred");
        _;
    }

    function signIn(string memory name) public {
        require(bytes(name).length > 0, "Name should not be empty");
        require(
            players[msg.sender].exists == false,
            "Player with this address alredy exists"
        );
        players[msg.sender] = (Player(name, 0, 0, 0, true));
        arrPlayers.push(msg.sender);
        playersCounter++;
        emit NewRegistred(msg.sender, name);
    }

    function playWithFriend(address opponent, Decision desidion)
        public
        onlyRegistred
    {
        require(players[opponent].exists, "Your oppenent not registred");

        gamesCount++;
        Game storage g = games[gamesCount];

        g.exists = true;
        g.p1 = msg.sender;
        g.p2 = opponent;
        g.playerDecisions[msg.sender] = PlayerDecision(
            true,
            GameState.UNKNOWN,
            desidion
        );
        g.playerDecisions[opponent] = PlayerDecision(
            false,
            GameState.UNKNOWN,
            Decision.UNKNOWN
        );

        emit InvetedToGame(opponent, gamesCount);
    }

    function makeDecision(uint256 gameId, Decision desidion)
        public
        onlyRegistred
    {
        address p1;
        address p2;
        GameState currentPlayerState;
        Game storage game = games[gameId];

        require(game.exists, "This game not exists");
        require(!game.complete, "This game ended");

        require(
            game.p1 == msg.sender || game.p2 == msg.sender,
            "You must be in this game"
        );

        p1 = game.p1;
        p2 = game.p2;
        if (msg.sender != game.p1) {
            p1 = game.p2;
            p2 = game.p1;
        }

        require(
            !game.playerDecisions[msg.sender].desided,
            "You already made the choise"
        );

        games[gameId].playerDecisions[msg.sender].desidion = desidion;
        games[gameId].playerDecisions[msg.sender].desided = true;

        if (game.playerDecisions[p1].desided) {
            games[gameId].complete = true;
            (currentPlayerState) = compareDesidions(
                game.playerDecisions[p1].desidion,
                game.playerDecisions[p2].desidion
            );

            games[gameId].playerDecisions[p1].gameState = currentPlayerState;
            if (currentPlayerState == GameState.WIN) {
                game.playerDecisions[p2].gameState = GameState.LOSE;
                players[p1].win++;
                players[p2].loss++;
            }
            if (currentPlayerState == GameState.LOSE) {
                game.playerDecisions[p2].gameState = GameState.WIN;
                players[p1].loss++;
                players[p2].win++;
            }
            if (currentPlayerState == GameState.DRAW) {
                game.playerDecisions[p2].gameState = GameState.DRAW;
                players[p1].draw++;
                players[p2].draw++;
            }
        }
    }

    event NewRegistred(address indexed walletAddress, string name);

    event InvetedToGame(address indexed walletAddress, uint256 gameId);
}
