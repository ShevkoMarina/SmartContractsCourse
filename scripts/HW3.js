const Web3 = require('web3')
var web3 = new Web3("https://eth-goerli.g.alchemy.com/v2/" + API_URL);
const address = "0x4EcACffE6d5b141DECDe91Ac62c747a8C64ea579";

// Смарт-контракт суммирует 2 числа и может возвращать результат суммирования
const ABI = [
    {
        "inputs": [
            {
                "internalType": "int256",
                "name": "num_1",
                "type": "int256"
            },
            {
                "internalType": "int256",
                "name": "num_2",
                "type": "int256"
            }
        ],
        "name": "add",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getSum",
        "outputs": [
            {
                "internalType": "int256",
                "name": "",
                "type": "int256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

web3.eth.getBalance ;

var myContract = new web3.eth.Contract(ABI, address);
myContract.methods.getSum().call().then(console.log);