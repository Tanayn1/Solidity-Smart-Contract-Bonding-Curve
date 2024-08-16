// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";



contract TokenMint is ERC20 {
    bool public liquidityCreated = false;
    bool public supplySold = false;
    address public reserveAccount;
    address public curveAccount;
    address public liquidityAccount;
    uint256 public constant INITITAL_PRICE = 0.01 ether; 
    uint256 public constant PRICE_SLOPE = 0.001 ether;

    constructor(string memory name, string memory symbol, address _reserveAccount, address _curveAccount, address _liquidityAccount) ERC20(name, symbol) {
        console.log("Constructor called with parameters:");
        console.log("_reserveAccount:", _reserveAccount);
        console.log("_curveAccount:", _curveAccount);
        console.log("_liquidityAccount:", _liquidityAccount);

        console.log("Minting tokens...");
        _mint(_reserveAccount, 20000000 * 10 ** decimals());
        _mint(_curveAccount, 80000000 * 10 ** decimals());

        reserveAccount = _reserveAccount;
        curveAccount = _curveAccount;
        liquidityAccount = _liquidityAccount;

        console.log("Minting complete. Checking balances:");
        console.log("Curve Account Balance", balanceOf(curveAccount));
        console.log("Reserve Account Balance", balanceOf(reserveAccount));
        console.log("Total Supply:", totalSupply());
    }
    //fix this 
    function calulatePrice(uint256 amount) public view returns(uint256) {
        uint256 currentSupply = balanceOf(curveAccount);
        console.log("Current Curve Account Supply", currentSupply);
        uint256 pricePerToken = INITITAL_PRICE + (currentSupply / 1 ether) * PRICE_SLOPE;
        console.log("Price Per Token", pricePerToken);
        console.log("Total Cost", pricePerToken * amount);
        return pricePerToken * amount;
    }

    function buy(uint amount) public payable {
        if (balanceOf(curveAccount) == 0 && !liquidityCreated) {
            supplySold = true;
            //add liquidity
        } else {
            require(balanceOf(curveAccount) >= amount, "Not enough supply");
            uint256 totalCost = calulatePrice(amount);
            console.log(totalCost);
            require(msg.value >= totalCost, "Not Enough BNB");
            (bool success, ) = liquidityAccount.call{value: msg.value}("");
            require(success, "Transfer to reserve account failed");
            _transfer(curveAccount, msg.sender, amount); 
            if (balanceOf(curveAccount) == 0) {
                supplySold = true;
                //add liquidty
            }
        }
    }

    function sell(uint amount) public {
        require(supplySold == false, "Supply has aldready been sold");
        uint256 sellPrice = calulatePrice(amount);
        console.log(sellPrice);
        _transfer(msg.sender, curveAccount, sellPrice);
        (bool success, ) = payable(msg.sender).call{value: sellPrice}("");
        require(success, "Transfer to seller failed");
    }

    function createLiquidityPool() public {}
}