// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DAOGovernor} from "../contracts/DAOGovernor.sol";
import {GOVToken} from "../contracts/GOVToken.sol";
import {TimelockControllerUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployDAO is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Token (Constructor needs a uint256, No initialize function exists)
        // This fixes Error 6160 and Error 9582
        GOVToken token = new GOVToken(1000000 ether); 
        console.log("Token Deployed at:", address(token));

        // 2. Deploy Timelock (Upgradeable version - empty constructor)
        TimelockControllerUpgradeable timelock = new TimelockControllerUpgradeable();
        
        address[] memory proposers = new address[](1);
        proposers[0] = deployer;
        address[] memory executors = new address[](1);
        executors[0] = address(0); 

        timelock.initialize(0, proposers, executors, deployer);
        console.log("Timelock Deployed at:", address(timelock));
        
        // 3. Deploy Governor Implementation
        DAOGovernor governorImpl = new DAOGovernor();

        // 4. Encode Initialization Data
        bytes memory initData = abi.encodeWithSelector(
            DAOGovernor.initialize.selector,
            "MyDAO",
            token,
            timelock,
            1,      
            50400,  
            0       
        );

        // 5. Deploy UUPS Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(governorImpl), initData);
        
        console.log("---------------------------");
        console.log("Governor Proxy Address:", address(proxy));
        console.log("---------------------------");

        vm.stopBroadcast();
    }
}