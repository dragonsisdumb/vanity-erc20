// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Script, console2} from "forge-std/Script.sol";
import {SHFL} from "../src/SHFL.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract VanityAddressScript is Script {
    bytes32 private _create2salt;
    address private _foundAddress;
    uint256 deployerPrivateKey;
    address deployer;
    SHFL public token;
        
    function setUp() public {
        // setup
        deployerPrivateKey = vm.envUint("DEPLOYER_PKEY");
        deployer = vm.addr(deployerPrivateKey);
    }

    function run() public {
        // Mine for the vanity address
        bool didMineAddress = mineForAddress();
        if(!didMineAddress) {
            console2.log("Did not mine address. Try increasing the iteration count!");
        } else {
            console2.log("\r\n");
            console2.log("Deployer address: %s", address(deployer));
            console2.log("Contract will be deployed to address: %s", address(_foundAddress));
            console2.log("\r\n\r\nSALT_FOR_VANITY_ADDRESS=%s forge script script/SHFL.s.sol:SHFLScript --fork-url http://localhost:8545 --broadcast", vm.toString(_create2salt));
        }
    }

    // Helper fns
    function mineForAddress() internal returns(bool) {
        // length calc
        string memory desiredStartsWith = vm.envString("CONTRACT_START_CHARS");
        uint8 startsWithLength = uint8(bytes(desiredStartsWith).length);

        string memory desiredEndsWith = vm.envString("CONTRACT_END_CHARS");
        uint8 endsWithLength = uint8(bytes(desiredEndsWith).length);

        bool didFindAddress = false;
        bytes32 foundSalt;

        uint256 _start = vm.envOr("START_SEED", uint256(0));

        // Mine for the vanity address
        for (uint256 i = _start; i < (_start + vm.envUint("MAX_ITERATIONS")); i++) {
            bytes32 _salt = keccak256(abi.encodePacked(i));

            bytes memory byteCode = abi.encodePacked(type(SHFL).creationCode, [address(deployer)]);

            address contractAddress = vm.computeCreate2Address(
                _salt, 
                keccak256(byteCode)
            );

            string memory caString = Strings.toHexString(contractAddress);

            string memory addressStartsWith = substring(caString
                , 2
                , startsWithLength+2);

            if(Strings.equal(addressStartsWith, desiredStartsWith)) {
                string memory addressEndsWith = substring(
                    caString
                    , 42-endsWithLength
                    , 42
                );
                
                if(Strings.equal(addressEndsWith, desiredEndsWith)) {
                    _foundAddress = contractAddress;
                    didFindAddress = true;
                    foundSalt = _salt;
                    break;
                }
            }
        }

        _create2salt = foundSalt;
        return didFindAddress;
    }

    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory ) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }
}

contract SHFLScript is Script {
    uint256 deployerPrivateKey;
    address deployer;
    SHFL public token;
        
    function setUp() public {
        // setup
        deployerPrivateKey = vm.envUint("DEPLOYER_PKEY");
        deployer = vm.addr(deployerPrivateKey);
    }

    function run() public {
        string memory _salt = vm.envString("SALT_FOR_VANITY_ADDRESS");
        uint256 convertedSalt = vm.parseUint(_salt);
        
        vm.startBroadcast(deployerPrivateKey);

        bytes memory byteCode = abi.encodePacked(type(SHFL).creationCode);
        address expectedAddress = vm.computeCreate2Address(
            bytes32(convertedSalt), 
            keccak256(byteCode)
        );

        // Deploy the contract with CREATE2 via 0x4e59b44847b379578588920cA78FbF26c0B4956C
        SHFL deployedAddress = new SHFL{ salt: bytes32(convertedSalt) }(address(deployer));

        vm.stopBroadcast();
    }
}
