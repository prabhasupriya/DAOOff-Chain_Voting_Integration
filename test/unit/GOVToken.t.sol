// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/GOVToken.sol";

contract GOVTokenTest is Test {
    GOVToken token;
    address public OWNER = address(0x1);
    address public USER = address(0x2);
    uint256 public constant AMOUNT = 1000 ether;

    function setUp() public {
        vm.prank(OWNER);
        token = new GOVToken(AMOUNT);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), AMOUNT);
        assertEq(token.balanceOf(OWNER), AMOUNT);
    }

    function testVotingPowerAndDelegation() public {
        vm.startPrank(OWNER);
        // Initially, voting power is 0 until delegated
        assertEq(token.getVotes(OWNER), 0);
        
        // Self-delegate to activate voting power
        token.delegate(OWNER);
        assertEq(token.getVotes(OWNER), AMOUNT);
        
        // Transfer tokens to USER
        token.transfer(USER, 100 ether);
        vm.stopPrank();

        // Check that voting power moved correctly
        assertEq(token.getVotes(OWNER), 900 ether);
        
        vm.prank(USER);
        token.delegate(USER);
        assertEq(token.getVotes(USER), 100 ether);
    }
}