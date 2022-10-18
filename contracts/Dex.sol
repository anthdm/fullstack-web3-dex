// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./Tokens.sol";

contract Dex {
    struct Pool {
        ERC20 tokenA;
        ERC20 tokenB;
        bool isOpen;
    }

    mapping(string => Pool) public pools;
    mapping(address => mapping(ERC20 => uint256)) public poolTokenBalances;

    function registerPool(ERC20 tokenA, ERC20 tokenB) public {
        string memory symbolA = tokenA.symbol();
        string memory symbolB = tokenB.symbol();
        string memory poolName = string.concat(symbolA, symbolB);

        pools[poolName] = Pool({tokenA: tokenA, tokenB: tokenB, isOpen: true});

        console.log("new pool registered: ", poolName);
    }

    function swap(
        string calldata poolName,
        ERC20 quoteToken,
        uint256 amount
    ) public {}

    function deposit(
        string calldata poolName,
        ERC20 token,
        uint256 amount
    ) public {
        require(pools[poolName].isOpen, "pool does not exist or is not opened");

        token.transferFrom(msg.sender, address(this), amount);
        poolTokenBalances[msg.sender][token] += amount;
    }

    function withdraw(
        string calldata poolName,
        ERC20 token,
        uint256 amount
    ) public {
        require(pools[poolName].isOpen, "pool does not exist or is not opened");
        require(poolTokenBalances[msg.sender][token] >= amount);

        token.approve(address(this), amount);
        token.transferFrom(address(this), msg.sender, amount);
        poolTokenBalances[msg.sender][token] -= amount;
    }
}
