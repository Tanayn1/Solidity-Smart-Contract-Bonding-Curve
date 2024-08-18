// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./BancorFormula.sol";

contract TokenMint is ERC20, BancorBondingCurve {
    bool public liquidityCreated = false;
    bool public supplySold = false;
    address public reserveAccount;
    address public liquidityAccount;
    uint256 constant public DECIMALS = 10**18;
    uint256 constant public INITIAL_MINT = (2 * 10 ** 8) * DECIMALS;
    uint constant public fundingGoal = 5 ether;
    uint32 public reserveRatio = 10;


    constructor(string memory name, string memory symbol, address _reserveAccount, address _liquidityAccount) ERC20(name, symbol) {
        console.log("Constructor called with parameters:");
        console.log("_reserveAccount:", _reserveAccount);
        console.log("_liquidityAccount:", _liquidityAccount);

        console.log("Minting tokens...");
        _mint(_reserveAccount, INITIAL_MINT);

        reserveAccount = _reserveAccount;
        liquidityAccount = _liquidityAccount;

        console.log("Minting complete. Checking balances:");
        console.log("Reserve Account Balance", balanceOf(reserveAccount));
    }

    function calculateContinuousMintReturn(uint256 _amount)
        public view returns (uint256)
    {
        console.log("amount", _amount);
        console.log("Total Supply", totalSupply());
        uint256 mintAmount = calculatePurchaseReturn(totalSupply(), balanceOf(reserveAccount), uint32(reserveRatio), _amount);
        console.log("Mint Amount",mintAmount);
        return mintAmount;

    }
 
}