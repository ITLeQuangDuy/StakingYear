const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const TokenUSDT = await ethers.getContractFactory("USDTToken");
    const tokenUSDT = await TokenUSDT.deploy();

    //const TokenEXM = await ethers.getContractFactory("EXMToken");
    //const tokenEXM = await TokenEXM.deploy();

    //const Staking = await ethers.getContractFactory("Staking");
    //const staking = await Staking.deploy();

    //await tokenUSDT.deployed();
    //await tokenEXM.deployed();
    //await staking.deployed();

    //console.log("TokenUSDT address to:", tokenUSDT.address);
    //console.log("TokenEXM deployed to:", tokenEXM.address);
    //console.log("Staking deployed to:", staking.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
