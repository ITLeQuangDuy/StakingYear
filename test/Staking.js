const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test Staking", async function(){
    let tokenEXM;
    let tokenUSDT;
    let staking;
    let owner;
    let signer;
    it("Deploy",async function () { 
        [owner, signer, signer1, signer2] = await ethers.getSigners();
        const TokenEXM = await ethers.getContractFactory("EXMToken");
        tokenEXM = await TokenEXM.deploy();
        
        const TokenUSDT = await ethers.getContractFactory("USDTToken");
        tokenUSDT = await TokenUSDT.deploy();
        
        const addrEXM = await tokenEXM.getAddress();
        const addrUSDT = await tokenUSDT.getAddress();

        const Staking = await ethers.getContractFactory("Staking");
        staking = await Staking.deploy(addrUSDT, addrEXM);
    });

    /*
    it("Staking", async function(){
        await tokenEXM.connect(owner).mint(owner, ethers.parseEther("1000"));
        const addrContract = await staking.getAddress();
        await tokenEXM.connect(owner).approve(addrContract, ethers.parseEther("1"));
        await tokenEXM.connect(owner).mint(addrContract, ethers.parseEther("100"));
        //await staking.connect(owner).stake(ethers.parseEther("1"));
        
        const duration = 31556926;
        await ethers.provider.send("evm_increaseTime", [duration]);

        //await staking.connect(owner).unstake();

        const reward = await staking.rewardAmount1(owner);
        console.log("reward", reward);
        console.log("stake time", await staking.stakeTime(owner));
        console.log("unstake time", await staking.unstakeTime(owner));
    })*/

    it("Reaward", async function(){
        
    })

    it("Staking with USDT Token", async function(){
        await tokenUSDT.connect(owner).mint(owner, ethers.parseEther("1000"));

        const addrContract = await staking.getAddress();

        await tokenUSDT.connect(owner).approve(addrContract, ethers.parseEther("100"));
        await staking.connect(owner).stake(1, ethers.parseEther("100"));

        const duration = 31556927;
        await ethers.provider.send("evm_increaseTime", [duration]);
        await staking.withdRaw(1);
        //await staking.connect(owner).unstake(1);
    })

    it("Staking with EXM Token", async function(){
        await tokenEXM.connect(owner).mint(owner, ethers.parseEther("1000"));

        const addrContract = await staking.getAddress();

        await tokenEXM.connect(owner).approve(addrContract, ethers.parseEther("500"));
        await staking.connect(owner).stake(2, ethers.parseEther("500"));

        const duration = 47335375;
        await ethers.provider.send("evm_increaseTime", [duration]);

        await staking.connect(owner).unstake(2);
    })
});