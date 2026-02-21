// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract GOVToken is ERC20, ERC20Permit, ERC20Votes {
    constructor(uint256 initialSupply) 
        ERC20("Governance Token", "GOV") 
        ERC20Permit("GOVToken") 
    {
        _mint(msg.sender, initialSupply);
    }

    // Required overrides for Solidity
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}