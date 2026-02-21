// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {DAOGovernor} from "../contracts/DAOGovernor.sol";

contract AttestOffchain is Script {
    // Note: Use 'address' in the parameters, but cast inside the function
    function run(address governorAddress, uint256 proposalId) external {
        // We cast to payable here to resolve Error 7398
        DAOGovernor governor = DAOGovernor(payable(governorAddress));
        
        vm.startBroadcast();
        governor.submitOffchainVoteResult(proposalId, true);
        vm.stopBroadcast();
    }
}