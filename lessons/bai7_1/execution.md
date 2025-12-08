# Contract 

```
    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.28;

    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";

    contract MyMintableToken is ERC20, Ownable {
        constructor() ERC20("DANGVUDEVMINT", "DVDEM") Ownable(msg.sender) {
        }

        function mint(address to, uint256 amount) public onlyOwner {
            _mint(to, amount);
        }
    }
```
---

# Deploy script

```
    import { DeployFunction } from "hardhat-deploy/types";
    import { HardhatRuntimeEnvironment } from "hardhat/types";

    const deployMyMintableToken: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    await deploy("MyMintableToken", {
        from: deployer,
        args: [],
        log: true,
    });

    const contract = await hre.ethers.getContract("MyMintableToken", deployer) as any;

    // Mint 1000 token DVDEM cho deployer (1000 * 10 ** 18)
    const amountToMint = hre.ethers.parseUnits("1000", 18);
    console.log("Minting 1000 DVDEM cho deployer...");

    const mintTx = await contract.mint(deployer, amountToMint);
    await mintTx.wait();

    // In balance
    const balance = await contract.balanceOf(deployer);
    console.log("Balance của deployer:", hre.ethers.formatEther(balance), "DVDEM");
    console.log("Contract address:", await contract.getAddress());
    };

    export default deployMyMintableToken;
    deployMyMintableToken.tags = ["mymintoken"];
```
--- 

# Result

```
    deploying "MyMintableToken" (tx: 0x90efb11b2422509830b7e39df6749580ecb260ea2d5fa901237992f9fad28108)...: deployed at 0xB1f1E96F451df133A43C5534bFDDC2f6A27FeeB0 with 645436 gas
    Minting 1000 DVDEM cho deployer...
    Balance của deployer: 1000.0 DVDEM
    Contract address: 0xB1f1E96F451df133A43C5534bFDDC2f6A27FeeB0
```
