// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/DAOGovernor.sol";
import "../../contracts/GOVToken.sol";
import "../../contracts/DAOTimelock.sol";
import "@openzeppelin/contracts/proxy/erc1967/ERC1967Proxy.sol";

contract DAOGovernorTest is Test {
    DAOGovernor governor;
    GOVToken token;
    DAOTimelock timelock;
    address public OWNER = address(0x1);

    function setUp() public {
        vm.startPrank(OWNER);
        // FIXED: 1 arg
        token = new GOVToken(1000 ether);
        
        address[] memory p = new address[](0);
        address[] memory e = new address[](0);
        timelock = new DAOTimelock(3600, p, e, OWNER);
        
        DAOGovernor implementation = new DAOGovernor();
        bytes memory data = abi.encodeWithSelector(
            DAOGovernor.initialize.selector,
            "DAO-System", token, timelock, uint48(1), uint32(50400), uint256(0)
        );
        
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);
        governor = DAOGovernor(payable(address(proxy)));
        
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        vm.stopPrank();
        vm.roll(block.number + 1);
    }

    function testSettings() public view {
        assertEq(governor.name(), "DAO-System");
    }
}