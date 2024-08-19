// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./BancorFormula.sol";

contract TokenMint is ERC20, BancorBondingCurve {
    bool public liquidityCreated = false;
    bool public supplySold = false;
    address public reserveAccount;
    uint256 constant public DECIMALS = 10**18;
    uint256 constant public INITIAL_MINT = (2 * 10 ** 8) * DECIMALS;
    uint256 constant public MAX_SUPPLY = (1 * 10 ** 9) * DECIMALS; // 1 billion tokens
    uint constant public fundingGoal = 5 ether;
    uint32 public reserveRatio = 1000;
    uint256 initialFunding = 0.00001 ether;



    constructor(string memory name, string memory symbol, address _reserveAccount) payable ERC20(name, symbol) {
        require(address(this).balance >= initialFunding, "Contract does not have enough Ether");
        console.log("Constructor called with parameters:");
        console.log("_reserveAccount:", _reserveAccount);

        console.log("Minting tokens...");
        _mint(_reserveAccount, INITIAL_MINT);

        reserveAccount = _reserveAccount;
        console.log("Minting and transfer complete complete. Checking balances:");
        console.log("Reserve Account Balance", balanceOf(reserveAccount) / DECIMALS);
        console.log("contract balance", address(this).balance);
    }

    function calculateContinuousMintReturn(uint256 _amount)
        public view returns (uint256)
    {
        console.log("Calculating Purchase Mint Amount");
        console.log("amount", _amount, _amount / 1e14);
        console.log("Total Supply", totalSupply() / DECIMALS);
        console.log("Balance of contract", address(this).balance);
        uint256 mintAmount = calculatePurchaseReturn(totalSupply(), address(this).balance, uint32(reserveRatio), _amount);
        console.log("Mint Amount", mintAmount / DECIMALS);
        return mintAmount;

    }

    function calculateContinuousMintBurnReturn(uint256 _amount) public view returns(uint256) {
        console.log("Calculating Sell Eth Amount");
        console.log("sell amount", _amount);
        console.log("Total Supply", totalSupply() / DECIMALS );
        console.log("Balance of contract ", address(this).balance);
        uint256 ethRefund = calculateSaleReturn(totalSupply(), address(this).balance , uint32(reserveRatio), _amount);
        console.log("Ethereum Refund", ethRefund);
        return ethRefund;
    }



    function buy() public payable {
        require(msg.value > 0, "Must send ether to buy tokens.");
        console.log("Balance Of Contract Account Before Buy", address(this).balance);
        uint256 tokenAmount = calculateContinuousMintReturn(msg.value);
        console.log("Minting Tokens", msg.sender, tokenAmount / DECIMALS);
        _mint(msg.sender, tokenAmount);
        console.log("Balance Of Contract After Buy", address(this).balance);

    }

    function sell(uint256 sellAmount) public {
        require(sellAmount > 0 && balanceOf(msg.sender) >= sellAmount, "Must have sell amount");
        require(supplySold == false, "Supply has been sold and liquidty has been created");
        console.log("Total Supply Before Burn", totalSupply() / DECIMALS );
        uint256 ethAmount = calculateContinuousMintBurnReturn(sellAmount);
        _burn(msg.sender, sellAmount);
        payable(msg.sender).transfer(ethAmount);
        console.log("Total Supply After Burn", totalSupply() / DECIMALS );

    }
 
}