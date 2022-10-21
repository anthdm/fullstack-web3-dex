// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./Tokens.sol";

contract Dex {
    struct Pool {
        mapping(string => ERC20) poolTokensSwapped;
        bool isOpen;
    }

    mapping(string => Pool) public pools;
    mapping(address => mapping(ERC20 => uint256)) public poolTokenBalances;

    function registerPool(ERC20 tokenA, ERC20 tokenB) public {
        string memory symbolA = tokenA.symbol();
        string memory symbolB = tokenB.symbol();
        string memory poolName = string.concat(symbolA, symbolB);

        Pool storage pool = pools[poolName];
        pool.isOpen = true;
        pool.poolTokensSwapped[symbolA] = tokenB;
        pool.poolTokensSwapped[symbolB] = tokenA;

        console.log("new pool registered: ", poolName);
    }

    function swap(
        string calldata poolName,
        ERC20 quoteToken,
        uint256 depositAmount
    ) public validPool(poolName) {
        ERC20 baseToken = pools[poolName].poolTokensSwapped[
            quoteToken.symbol()
        ];

        uint256 baseTokensToReturn = calculateTokenSwap(
            poolName,
            quoteToken,
            depositAmount
        );
        require(
            baseToken.balanceOf(address(this)) > baseTokensToReturn,
            "not enough base tokens in the pool"
        );

        quoteToken.transferFrom(msg.sender, address(this), depositAmount);

        baseToken.approve(address(this), baseTokensToReturn);
        baseToken.transferFrom(address(this), msg.sender, baseTokensToReturn);
    }

    function deposit(
        string calldata poolName,
        ERC20 token,
        uint256 amount
    ) public validPool(poolName) {
        token.transferFrom(msg.sender, address(this), amount);
        poolTokenBalances[msg.sender][token] += amount;
    }

    function withdraw(
        string calldata poolName,
        ERC20 token,
        uint256 amount
    ) public validPool(poolName) {
        require(poolTokenBalances[msg.sender][token] >= amount);

        token.approve(address(this), amount);
        token.transferFrom(address(this), msg.sender, amount);
        poolTokenBalances[msg.sender][token] -= amount;
    }

    function calculateTokenSwap(
        string calldata poolName,
        ERC20 quoteToken,
        uint256 depositAmount
    ) public view returns (uint256) {
        require(
            quoteToken.balanceOf(address(this)) > 0,
            "balance of tokens in pool cannot be zero"
        );

        ERC20 baseToken = pools[poolName].poolTokensSwapped[
            quoteToken.symbol()
        ];
        require(
            baseToken.balanceOf(address(this)) > 0,
            "balance of tokens in pool cannot be zero"
        );

        uint256 price = getPrice(poolName, baseToken);

        return depositAmount / price;
    }

    // X * Y = K
    function getPrice(string calldata poolName, ERC20 baseToken)
        public
        view
        returns (uint256)
    {
        ERC20 quoteToken = pools[poolName].poolTokensSwapped[
            baseToken.symbol()
        ];

        uint256 quoteTokenSupply = quoteToken.balanceOf(address(this));
        uint256 baseTokenSupply = baseToken.balanceOf(address(this));

        return quoteTokenSupply / baseTokenSupply;
    }

    modifier validPool(string calldata poolName) {
        assert(pools[poolName].isOpen == true);
        _;
    }
}
