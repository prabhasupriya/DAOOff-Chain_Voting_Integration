// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DAOGovernor} from "../contracts/DAOGovernor.sol";

contract ProposeAction is Script {
    function run() external {
        uint256 privateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        // Use your Governor Proxy Address here
        DAOGovernor governor = DAOGovernor(payable(0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9));

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(0x1); // Dummy target
        values[0] = 0;
        calldatas[0] = "";
        string memory description = "Proposal #1: Test Governance";

        vm.startBroadcast(privateKey);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        console.log("Proposal Created! ID:", proposalId);
        vm.stopBroadcast();
    }
}