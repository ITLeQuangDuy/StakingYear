const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test Staking", async function(){
    let tokenEXM;
    let tokenUSDT;
    let staking;
    let owner;
    let signer1;
    let signer2;
    let addrEXM;
    let addrUSDT;

    const increaseTime = async (ms) => {
        network.provider.send("evm_increaseTime", [ms]);
        await network.provider.send("evm_mine");
    };

    it("Deploy",async function () { 
        [owner, signer1, signer2] = await ethers.getSigners();
        const TokenEXM = await ethers.getContractFactory("EXMToken");
        tokenEXM = await TokenEXM.deploy();
        
        const TokenUSDT = await ethers.getContractFactory("USDTToken");
        tokenUSDT = await TokenUSDT.deploy();
        
        addrEXM = await tokenEXM.getAddress();
        addrUSDT = await tokenUSDT.getAddress();

        const Staking = await ethers.getContractFactory("Staking");
        staking = await Staking.deploy();
    });

    it("Add Pool 1", async function(){
        const _tokenAddress = addrUSDT;
        const _lockDuration = 31556926;
        const _rewardDuration = 259200;
        const _minStakeAmount = ethers.parseEther("100");
        const _maxStakeAmount = ethers.parseEther("10000");
        const _maxPoolAmount = ethers.parseEther("1000000");
        const _percent = 65;
        
        await staking.connect(owner).addPool(_tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent);
    });

    it("Add Pool 2", async function(){
        const _tokenAddress = addrEXM;
        const _lockDuration = 47335374;
        const _rewardDuration = 604800;
        const _minStakeAmount = ethers.parseEther("500");
        const _maxStakeAmount = ethers.parseEther("50000");
        const _maxPoolAmount = ethers.parseEther("5000000");
        const _percent = 75;
        
        await staking.connect(owner).addPool(_tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent);
    });

    it("Add Pool 3", async function(){
        const _tokenAddress = addrEXM;
        const _lockDuration = 47335374;
        const _rewardDuration = 604800;
        const _minStakeAmount = ethers.parseEther("500");
        const _maxStakeAmount = ethers.parseEther("50000");
        const _maxPoolAmount = ethers.parseEther("5000000");
        const _percent = 75;
        
        await staking.connect(owner).addPool(_tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent);
    });

    //ngoai le
    it("Add Pool 4", async function(){
        const _tokenAddress = "0x0000000000000000000000000000000000000000";
        const _lockDuration = 47335374;
        const _rewardDuration = 604800;
        const _minStakeAmount = ethers.parseEther("100");
        const _maxStakeAmount = ethers.parseEther("100");
        const _maxPoolAmount = ethers.parseEther("199");
        const _percent = 75;
        
        await expect (staking.connect(owner).addPool(_tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent)).to.be.revertedWith("Invalid token address");
    });

    it("Update Pool 3", async function(){
        const poolId = 3;
        const _tokenAddress = addrUSDT;
        const _lockDuration = 44444444;
        const _rewardDuration = 666666;
        const _minStakeAmount = ethers.parseEther("100");
        const _maxStakeAmount = ethers.parseEther("100");
        const _maxPoolAmount = ethers.parseEther("199");
        const _percent = 100;

        await staking.connect(owner).updatePool(poolId, _tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent);

        const updatedPool = await staking.getRound(poolId);

        expect(updatedPool.tokenAddress).to.equal(_tokenAddress);
        expect(updatedPool.lockDuration).to.equal(_lockDuration);
        expect(updatedPool.rewardDuration).to.equal(_rewardDuration);
        expect(updatedPool.minStakeAmount).to.equal(_minStakeAmount);
        expect(updatedPool.maxStakeAmount).to.equal(_maxStakeAmount);
        expect(updatedPool.maxPoolAmount).to.equal(_maxPoolAmount);
        expect(updatedPool.percent).to.equal(_percent);
    });

    //ngoai le
    it("Update Pool Invalid pool ID", async function(){
        const poolId = 5;
        const _tokenAddress = addrUSDT;
        const _lockDuration = 44444444;
        const _rewardDuration = 666666;
        const _minStakeAmount = ethers.parseEther("700");
        const _maxStakeAmount = ethers.parseEther("70000");
        const _maxPoolAmount = ethers.parseEther("7000000");
        const _percent = 100;

        await expect(staking.connect(owner).updatePool(poolId, _tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent)).to.be.revertedWith("Invalid pool ID");
    });

    //ngoai le
    it("Update Pool Invalid address", async function(){
        const poolId = 3;
        const _tokenAddress = "0x0000000000000000000000000000000000000000";
        const _lockDuration = 44444444;
        const _rewardDuration = 666666;
        const _minStakeAmount = ethers.parseEther("10");
        const _maxStakeAmount = ethers.parseEther("100");
        const _maxPoolAmount = ethers.parseEther("190");
        const _percent = 100;

        await expect(staking.connect(owner).updatePool(poolId, _tokenAddress, _lockDuration, _rewardDuration, _minStakeAmount, _maxStakeAmount, _maxPoolAmount, _percent)).to.be.revertedWith("Invalid address");
    });

    // ngoai le
    it("Get Pool", async function(){
        const poolId = 4;

        await expect(staking.getRound(poolId)).to.be.revertedWith("Pool does not exist");
    });

    //ngoai le
    it("Staking with USDT Token Invalid pool ID", async function(){
        const poolId = 4;
        const amountStake = ethers.parseEther("200");

        await expect(staking.connect(owner).stake(poolId, amountStake)).to.be.revertedWith("Invalid pool ID");
    });

    //ngoai le
    it("Staking with USDT Amount is less than minimum stake amount", async function(){
        const poolId = 1;
        const amountStake = ethers.parseEther("90");

        await expect(staking.connect(owner).stake(poolId, amountStake)).to.be.revertedWith("Amount is less than minimum stake amount");
    });

    //ngoai le 
    it("Staking with USDT Amount is greater than maximum stake amount", async function(){
        const poolId = 1;
        const amountStake = ethers.parseEther("10001");

        await expect(staking.connect(owner).stake(poolId, amountStake)).to.be.revertedWith("Amount is greater than maximum stake amount");
    });

    //ngoai le
    it("Staking with USDT Exceeds maximum pool amount", async function(){
        const poolId = 3;
        const amountStake = ethers.parseEther("100");

        await tokenUSDT.connect(owner).mint(owner.address, amountStake);
        await tokenUSDT.connect(owner).mint(signer1.address, amountStake);
        await tokenUSDT.connect(owner).approve(staking.target, amountStake);
        await tokenUSDT.connect(signer1).approve(staking.target, amountStake);
        await staking.connect(signer1).stake(poolId, amountStake)

        await expect(staking.connect(owner).stake(poolId, amountStake)).to.be.revertedWith("Exceeds maximum pool amount");
    });

    it("Staking with USDT Token", async function(){
        const poolId = 1;
        const amountStake = ethers.parseEther("200");

        await tokenUSDT.connect(owner).mint(owner.address, amountStake);
        await tokenUSDT.connect(owner).approve(staking.target, amountStake);
        const approveToContractBefore = await tokenUSDT.allowance(owner.address, staking.target);
        await staking.connect(owner).stake(poolId, amountStake);
        const approveToContractAfter = await tokenUSDT.allowance(owner.address, staking.target);
        const userStake = await staking.userStakes(owner.address, poolId);
        
        expect(amountStake).to.equal(userStake[0]);
        expect(approveToContractBefore).to.equal(amountStake + approveToContractAfter);
    });

    it("Staking with EXM Token", async function(){
        const poolId = 2;
        const amountStake = ethers.parseEther("600")

        await tokenEXM.connect(owner).mint(owner.address, amountStake);
        await tokenEXM.connect(owner).approve(staking.target, amountStake);
        const approveToContractBefore = await tokenEXM.allowance(owner.address, staking.target);
        await staking.connect(owner).stake(poolId, amountStake);
        const approveToContractAfter = await tokenEXM.allowance(owner.address, staking.target);
        const userStake = await staking.userStakes(owner.address, poolId);

        expect(amountStake).to.equal(userStake[0]);
        expect(approveToContractBefore).to.equal(amountStake + approveToContractAfter);
    });

    //ngoai le
    it("WithdRaw Reward USDT Token Not enough time to withdraw If", async function(){
        const poolId = 1;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("Not enough time to withdraw 1");
    });

    it("WithdRaw Reward USDT Token", async function(){
        const poolId = 1;
        const reward1 = parseFloat(ethers.formatEther("106778461248094950")).toFixed(5);
        const balanceOfUSDTBefore = await tokenUSDT.balanceOf(owner.address);
        
        increaseTime(259200);
        await staking.connect(owner).claimReward(poolId);
        
        const balanceOfUSDTAfter = await tokenUSDT.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfUSDTAfter - balanceOfUSDTBefore)).toFixed(5);
        
        expect(reward1).to.equal(reward2); 
    });// +3 days

    //ngoai le
    it("WithdRaw Reward USDT Token Not enough time to withdraw Else", async function(){
        const poolId = 1;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("Not enough time to withdraw 2");
    });

    //ngoai le
    it("WithdRaw Reward EXM Token Not enough time to withdraw If", async function(){
        const poolId = 2;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("Not enough time to withdraw 1");
    });

    it("WithdRaw Reward EXM Token", async function(){
        const poolId = 2;
        const reward1 = parseFloat(ethers.formatEther("985647334597799544")).toFixed(5);
        const balanceOfEXMBefore = await tokenEXM.balanceOf(owner.address);
        
        increaseTime(432000);
        await staking.connect(owner).claimReward(poolId);
        
        const balanceOfEXMAfter = await tokenEXM.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfEXMAfter - balanceOfEXMBefore)).toFixed(5);

        expect(reward1).to.equal(reward2);
    });// +5 days

    it("WithdRaw Reward EXM Token Not enough time to withdraw Else", async function(){
        const poolId = 2;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("Not enough time to withdraw 2");
    });

    it("WithdRaw Reward EXM Token 1 Year", async function(){
        const poolId = 2;
        const reward1 = parseFloat(ethers.formatEther("44014362665402200456")).toFixed(5);
        const balanceOfEXMBefore = await tokenEXM.balanceOf(owner.address);
        
        increaseTime(30865726);  
        await staking.connect(owner).claimReward(poolId);

        const balanceOfEXMAfter = await tokenEXM.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfEXMAfter - balanceOfEXMBefore)).toFixed(5);

        expect(reward1).to.equal(reward2);
    });// +1 year(-8 days)

    it("WithdRaw Reward USDT Token 1 Year", async function(){
        const poolId = 1;
        const reward1 = parseFloat(ethers.formatEther("12893221538751905050")).toFixed(5);
        const balanceOfUSDTBefore = await tokenUSDT.balanceOf(owner.address);

        await staking.connect(owner).claimReward(poolId);
        
        const balanceOfUSDTAfter = await tokenUSDT.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfUSDTAfter - balanceOfUSDTBefore)).toFixed(5);

        expect(reward1).to.equal(reward2);
    });

    it("UnStake USDT Token", async function(){
        const poolId = 1;
        const reward1 = parseFloat(ethers.formatEther("1083332990038383333")).toFixed(5);
        const amountStaking = ethers.parseEther("200")

        await tokenUSDT.connect(owner).mint(staking.target, amountStaking);

        const balanceContractBefore = await tokenUSDT.balanceOf(staking.target);
        const balanceOfSignerBefore = await tokenUSDT.balanceOf(owner.address);
        
        increaseTime(2629743);

        await staking.connect(owner).unStake(poolId);

        const balanceContractAfter = await tokenUSDT.balanceOf(staking.target);
        const balanceOfSignerAfter = await tokenUSDT.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfSignerAfter - balanceOfSignerBefore - amountStaking)).toFixed(5);
        
        expect(reward1).to.equal(reward2);
        expect(balanceContractBefore - balanceContractAfter).to.equal(balanceOfSignerAfter - balanceOfSignerBefore);
    });

    it("UnStake EXM Token", async function(){
        const poolId = 2;
        const reward1 = parseFloat(ethers.formatEther("26249984551727249986")).toFixed(5);
        const amountStaking = ethers.parseEther("600")

        await tokenEXM.connect(owner).mint(staking.target, amountStaking);

        const balanceContractBefore = await tokenEXM.balanceOf(staking.target);
        const balanceOfSignerBefore = await tokenEXM.balanceOf(owner.address);
        
        increaseTime(15778448);
        await staking.connect(owner).unStake(poolId);

        const balanceContractAfter = await tokenEXM.balanceOf(staking.target);
        const balanceOfSignerAfter = await tokenEXM.balanceOf(owner.address);
        const reward2 = parseFloat(ethers.formatEther(balanceOfSignerAfter - balanceOfSignerBefore - amountStaking)).toFixed(5);
        
        expect(reward1).to.equal(reward2);
        expect(balanceContractBefore - balanceContractAfter).to.equal(balanceOfSignerAfter - balanceOfSignerBefore);
    });//+6 months => 18 months

    it("Withdraw Reward USDT Token No staked amount", async function(){
        const poolId = 1;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("No staked amount");
    });

    it("UnStake EXM Token No staked amount", async function(){
        const poolId = 2;
        await expect(staking.connect(owner).claimReward(poolId)).to.be.revertedWith("No staked amount");
    });
});

