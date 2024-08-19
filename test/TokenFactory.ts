import { expect } from "chai";
import hre from "hardhat";


describe("Token Creation", function() {
    async function deploymentOfContract() {
        const tokenFactory = await hre.ethers.getContractFactory("TokenMint"); 
        const [ owner, reserveWallet, liquidityWallet ] = await hre.ethers.getSigners();

        const etherAmount = hre.ethers.parseEther("0.00001"); // 0.00001 Ether
        const token = await tokenFactory.deploy("Raygun", "RAY", reserveWallet.address, {value: etherAmount});

        return { token,  reserveWallet, liquidityWallet, owner }
    };

    it("Should Caluculate the price correctly", async function() {
        const { token,  reserveWallet, liquidityWallet, owner } = await deploymentOfContract();
        const ether = hre.ethers.parseEther("0.005")
        await token.buy({value: ether});
        await token.sell(3);        
    });

    // it("Should buy 100 raygun tokens", async function() {
    //     const { token, curveWallet, reserveWallet, liquidityWallet, owner } = await deploymentOfContract();
    //     const buyAmount = 100; // Number of tokens to buy
    //     const pricePerToken = await token.calulatePrice(buyAmount);
    //     const totalCost = pricePerToken;
    
    //     // Buy tokens by sending ETH
    //     const transaction = await token.connect(owner).buy(buyAmount, { value: totalCost });
    //     await transaction.wait();
    
    //     // Check if the tokens have been transferred
    //     const ownerBalance = await token.balanceOf(owner.address);
    //     console.log(ownerBalance)
    //     expect(ownerBalance).to.equal(buyAmount);
    
    //     // Check if the ETH has been transferred to the liquidity account
    //     const liquidityBalance = await hre.ethers.provider.getBalance(liquidityWallet.address);
    //     expect(liquidityBalance).to.equal(totalCost);
    // });
});

