// SPDX-License-Identifier: MIT

/**
 * Basic ERC20 token contract based on OpenZeppelin
 * I have used Shuffles implementation for this demo
 * that extends the interface to include a public
 * function to burn a number tokens from the sender 
 * address. 
 * 
 * Shuffle: 0x8881562783028F5c1BCB985d2283D5E170D88888 (chainid: 0x1)
 * 
 * The below is a copy/paste from their verified contract
 * source from Etherscan, minus a small change to line 23
 * since we proxy the create through a deployer we should not
 * send the tokens to msg.sender.
 */

pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SHFL is ERC20 {
    constructor(address _owner) ERC20("Shuffle", "SHFL") {
        _mint(_owner, 1000000000000000000000000000); // 1 billion
    }

    function burn(uint256 value) public {
        _update(_msgSender(), address(0xdead), value);
    }
}

// Use Promo Code LFGSHFL ;)