// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {SHFL} from "../src/SHFL.sol";

contract SHFLTest is Test {
    SHFL public token;
    address deployer;
    address user;

    bytes32 _create2salt = bytes32("dragonsisdumb");
    address _deterministicAddress = address(0x749084F8cb9D9b6aE757591fC5427832B25B7180);

    /**
     * Sets up 2 addresses and deploys SHFL contract.
     */
    function setUp() public {
        deployer = vm.addr(1);
        user = vm.addr(2);

        hoax(deployer);
        token = new SHFL{salt: _create2salt}(address(deployer));
    }

    /**
     * Ensures the byte code hash is correct for the deterministic address
     * calculation with CREATE2.
     * 
     * Everytime we modify src/SHFL.sol the hash for expectedByteCode will change
     */
    function test_getInitCode() public pure {
        bytes memory byteCode = abi.encodePacked(type(SHFL).creationCode);
        bytes32 expectedByteCode = bytes32(hex"5bd3110ede7ac0cb5564d56930be279e7efbd3bb0205b8b465372d706dcbe3b3");

        assert(keccak256(byteCode) == expectedByteCode);
    }

    /**
     * Redeploys SHFL with nonce 0x0 with CREATE2 method
     * and checks to see if the contract address is
     * deterministic.
     */
    function test_create2Deploy() public view {
        assert(address(token) == _deterministicAddress);

        uint256 nonce = vm.getNonce(deployer);
        assert(nonce == 0x1);
    }

    /**
     * Redeploys SHFL with nonce 0x69 with CREATE2 method
     * with a different salt and checks to see if the address
     * is not the deterministic one from the runs above.
     */
    function test_create2DeployWithWrongSalt() public {
        hoax(deployer);
        token = new SHFL{salt: "mandycalmdown"}(address(deployer));
        
        assert(
            (address(token) != _deterministicAddress)
            && (address(token) == address(0xCA8900c2FCF14694e2Fa68d93854cff5D9fAb189))
        );
    }

    /**
     * Tests to ensure the balance after the burn
     * is removed from the sender.
     */
    function test_burn() public {
        // Fetch the tokens owned by the deployer
        uint256 balanceBefore = token.balanceOf(deployer);

        // Burn the tokens the deployer owns AS the deployer
        vm.prank(deployer);
        token.burn(balanceBefore);

        // Check to see if the tokens are burned
        uint256 balanceAfter = token.balanceOf(deployer);
        assert( 
            (balanceBefore > balanceAfter) 
            && (balanceAfter == 0)
        );
    }
}
