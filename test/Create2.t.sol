// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {SHFL} from "../src/SHFL.sol";
import {Create2} from "../src/Create2.sol";

contract Create2Test is Test {
    Create2 internal create2;
    SHFL internal token;

    address deployer;

    function setUp() public {
        deployer = vm.addr(1);

        create2 = new Create2();
        token = new SHFL(deployer);
    }

    function testDeterministicDeploy() public {
        vm.deal(address(0x1), 100 ether);

        vm.startPrank(address(0x1));  
        bytes32 salt = "1234";
        bytes memory creationCode = abi.encodePacked(type(SHFL).creationCode, [address(deployer)]);

        address computedAddress = create2.computeAddress(salt, keccak256(creationCode));
        address deployedAddress = create2.deploy(salt , creationCode);
        vm.stopPrank();

        assertEq(computedAddress, deployedAddress);
        console.log("%s: %s", "Deployed at", computedAddress);  
    }

}