// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Treasury is Ownable, ReentrancyGuard {
    
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event FundsDeposited(address indexed sender, uint256 amount);

    constructor(address _governanceTimelock) Ownable(_governanceTimelock) {}

    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Only the Timelock (controlled by the DAO) can call this
    function withdrawFunds(address payable recipient, uint256 amount) external onlyOwner nonReentrant {
        require(address(this).balance >= amount, "Treasury: Insufficient balance");
        
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Treasury: Transfer failed");
        
        emit FundsWithdrawn(recipient, amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}