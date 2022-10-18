// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdcToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("USDC", "USDC") {
        _mint(msg.sender, initialSupply);
    }
}

contract GGToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("GGToken", "GG") {
        _mint(msg.sender, initialSupply);
    }
}
