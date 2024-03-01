// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Lottery Contract 
contract Lottery {
  
    // Global variables 
    address public manager;  
    address payable[] public lotteryBuyers;  

    constructor() {
        manager = msg.sender;
    }

    modifier onlyContractOwner() {
        require(msg.sender == manager, "Only contract owner");
        _;
    }

    // Receive payable function for deposits 
    receive() payable external {
        require(msg.value >= 1 ether, 'Not minimum value');
        require(msg.sender != manager, 'Manager cannot buy ticket');
        lotteryBuyers.push(payable(msg.sender));
    }

    // Showing contract balance
    function getBalance() view public returns(uint) {
        require(msg.sender == manager, 'Not manager');
        return address(this).balance;
    }

    // Generating random number
    function generateRandom() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, lotteryBuyers.length)));
    }

    // Get total number of buyers
    function getTotalNumberOfBuyers() public view returns(uint) {
        return lotteryBuyers.length;
    }

    // Select winner
    function selectWinner() external onlyContractOwner {
        require(lotteryBuyers.length >= 3, "At least 3 participants required");

        uint randomIndex = generateRandom() % lotteryBuyers.length;
        address payable winner = lotteryBuyers[randomIndex];
        
        // Transfer balance to the winner
        winner.transfer(getBalance());
        
        // Clear lottery buyers array
        delete lotteryBuyers;
    }

    // Transfer balance to the winner and clear the participants list 
    function reloadLottery() external onlyContractOwner {
        delete lotteryBuyers;
    }
}
