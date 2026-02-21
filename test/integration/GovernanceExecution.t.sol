// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/GOVToken.sol";
import "../../contracts/DAOTimelock.sol";
import "../../contracts/DAOGovernor.sol";
import "../../contracts/Treasury.sol";
import "@openzeppelin/contracts/proxy/erc1967/ERC1967Proxy.sol";

contract GovernanceExecutionTest is Test {
    GOVToken token;
    DAOTimelock timelock;
    DAOGovernor governor;
    Treasury treasury;

    address public voter = address(1);
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        // FIX: Only one argument (initial supply)
        token = new GOVToken(INITIAL_SUPPLY);
        
        address[] memory empty = new address[](0);
        timelock = new DAOTimelock(3600, empty, empty, address(this));
        
        // Ensure Treasury gets timelock address
        treasury = new Treasury(address(timelock));

        DAOGovernor implementation = new DAOGovernor();
        bytes memory initData = abi.encodeWithSelector(
            DAOGovernor.initialize.selector,
            "DAO Governor",
            token,
            timelock,
            uint48(1),
            uint32(50400),
            uint256(0)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        governor = DAOGovernor(payable(address(proxy)));

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        token.transfer(voter, INITIAL_SUPPLY);
        vm.prank(voter);
        token.delegate(voter);
        
        vm.deal(address(treasury), 10 ether);
    }

    function testFullGovernanceFlow() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(treasury);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("withdrawFunds(address,uint256)", address(99), 1 ether);

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Withdrawal test");

        vm.roll(block.number + governor.votingDelay() + 1);
        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + governor.votingPeriod() + 1);
        governor.queue(targets, values, calldatas, keccak256(bytes("Withdrawal test")));

        vm.warp(block.timestamp + 3601);
        governor.execute(targets, values, calldatas, keccak256(bytes("Withdrawal test")));

        assertEq(address(99).balance, 1 ether);
    }
}