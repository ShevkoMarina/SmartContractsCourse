const { expect } = require("chai");

describe("Calling from proxy", function () {
  it("Sign in by calling proxy", async function () {
    // Генерируем игроков
    const [owner, opponent, proxyDel] = await ethers.getSigners();

    // Разворачиваем контракт игры
    const GameContract = await ethers.getContractFactory("PaperRockScissors");
    const gameContract = await GameContract.deploy();
    console.log("Game deployed to address:", gameContract.address);

    // Регистрируем двух пользователей
    await gameContract.connect(owner).signIn('Player1');
    await gameContract.connect(opponent).signIn('Player2');

    // Разворачиваем контракт проксирующий вызов
    const ProxyContract = await ethers.getContractFactory("ProxyRPS");
    const proxyContract = await ProxyContract.deploy(gameContract.address);
    console.log("Proxy deployed to address:", proxyContract.address);

    // Дергаем метод регистрации через proxy-контракт
     await proxyContract.callSignIn('ProxyPlayer');

     // Проверяем что изменились значения в контракте игры
     var proxyPlayerInfo = await gameContract.players(proxyContract.address);
     await expect(proxyPlayerInfo.name).to.equal('ProxyPlayer');
     await expect(proxyPlayerInfo.exists).to.equal(true);

    // Проверяем что если использовать deligate изменения произойдет в контракте proxy
    await proxyContract.connect(proxyDel).delegateCallSignIn('ProxyDelPlayer');

    var proxyPlayerInfo = await proxyContract.playersCounter();
    await expect(proxyPlayerInfo).to.equal(1);
    var proxyPlayerInfo = await proxyContract.players(proxyDel.address);
    await expect(proxyPlayerInfo.name).to.equal('ProxyDelPlayer');
  });
});

describe("Start a game", function () {
  it("Start game when both players are registed", async function () {

      const [player1, player2] = await ethers.getSigners();

      // Разворачиваем контракт игры
      const GameContract = await ethers.getContractFactory("PaperRockScissors");
      const gameContract = await GameContract.deploy();
      console.log("Game deployed to address:", gameContract.address);

      // Регистрируем обоих пользователей
      await gameContract.connect(player1).signIn('Player1');
      await gameContract.connect(player2).signIn('Player2');

      // Первый ползователь начинает игру с другом и ставит на камень
      var gameStart = await gameContract
      .connect(player1)
      .playWithFriend(player2.address, Decision.ROCK);

      await expect(gameStart).to
      .emit(gameContract, "InvetedToGame").withArgs(player2.address, 1);
      var game = await gameContract.games(1);
      await expect(game.exists).to.equal(true);

  })
  it("Start game when not regested player trying to start a game", async function () {

    const [player1, player2] = await ethers.getSigners();

    const GameContract = await ethers.getContractFactory("PaperRockScissors");
    const gameContract = await GameContract.deploy();
    console.log("Game deployed to address:", gameContract.address);

    var gameStart = gameContract
    .connect(player1)
    .playWithFriend(player2.address, Decision.ROCK);

    await expect(gameStart).to.be.revertedWith('You are not registred');
})
it("Start game when opponent not regested ", async function () {

  const [player1, player2] = await ethers.getSigners();

  const GameContract = await ethers.getContractFactory("PaperRockScissors");
  const gameContract = await GameContract.deploy();
  console.log("Game deployed to address:", gameContract.address);

  await gameContract.connect(player1).signIn('Player1');

  var gameStart = gameContract
  .connect(player1)
  .playWithFriend(player2.address, Decision.ROCK);

  await expect(gameStart).to.be.revertedWith('Your oppenent not registred');
})
});


describe("Play a game", function () {
  it("Play game with player 1 win", async function () {

      const [player1, player2] = await ethers.getSigners();

      // Разворачиваем контракт игры
      const GameContract = await ethers.getContractFactory("PaperRockScissors");
      const gameContract = await GameContract.deploy();
      console.log("Game deployed to address:", gameContract.address);

      // Регистрируем обоих пользователей
      await gameContract.connect(player1).signIn('Player1');
      await gameContract.connect(player2).signIn('Player2');

      // Первый ползователь начинает игру с другом и ставит на камень
      await gameContract
      .connect(player1)
      .playWithFriend(player2.address, Decision.ROCK);

      var gameResult = await gameContract.connect(player2).games(1);
      console.log(gameResult);

      // Второй ползователь ставит ножницы
      await gameContract.connect(player2).makeDecision(1, Decision.SCISSORS);

      var gameResult = await gameContract.getGame(1);
      expect(gameResult.winner).to.equal(player1.address);
      expect(gameResult.loser).to.equal(player2.address);
      expect(gameResult.draw).to.equal(false);
      expect(gameResult.gameEnded).to.equal(true);
  })
});

const Decision = {
  UNKNOWN: 0,
  PAPER: 1,
  ROCK: 2,
  SCISSORS: 3
}