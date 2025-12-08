import { ethers } from "ethers";

async function main() {
  const provider = new ethers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/2W2pZ23QwENfN4wbgBfmVMslzHE7wLh_");

  const abi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "allowance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientAllowance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientBalance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "approver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidApprover",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidReceiver",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSpender",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
  ];


  const contractAddress = "0x995cbF88F691FCc800E686908566D14f69Bf4c75"; 
  const deployerAddress = "0x7eff82613404ae7bce622ea1c927214e30f2285e";
  const contract = new ethers.Contract(contractAddress, abi, provider);

  /**
   * Get the current balance of deployer
   */

  const blanceOfDeployer = await contract.balanceOf(deployerAddress);

  console.log('Balance of deployer: ', blanceOfDeployer.toString());
}

main().catch(console.error);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT - RESULT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


      // PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> npx ts-node run.ts bai6_1
      // ✅ Đã chạy xong bài: bai6_1
      // Balance of deployer:  1000000000000000000000000
      // PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> 



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT - CONTRACT 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      // SPDX-License-Identifier: MIT
      // pragma solidity ^0.8.28;

      // import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


      // contract MyToken is ERC20 {
      //     uint256 constant TOTAL_TOKEN = 1_000_000 * 10 ** 18;

      //     constructor() ERC20("J97Token", "J97") {
      //         _mint(msg.sender, TOTAL_TOKEN);
      //     }
      // }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DEPLOY - DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY -DEPLOY
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


      // PS D:\Blockchain\ac-hardhat-template> npx hardhat deploy --network sepolia --tags mytoken
      // Generating typings for: 8 artifacts in dir: typechain for target: ethers-v6
      // Successfully generated 34 typings!
      // Compiled 6 Solidity files successfully (evm target: paris).
      //  ·------------------------|--------------------------------|--------------------------------·
      //  |  Solc version: 0.8.28  ·  Optimizer enabled: true       ·  Runs: 1000                    │
      //  ·························|································|·································
      //  |  Contract Name         ·  Deployed size (KiB) (change)  ·  Initcode size (KiB) (change)  │
      //  ·························|································|·································
      //  |  Counter               ·                 0.246 (0.000)  ·                 0.271 (0.000)  │
      //  ·························|································|·································
      //  |  MyToken               ·                      1.744 ()  ·                      2.692 ()  │
      //  ·------------------------|--------------------------------|--------------------------------·
      // ====================
      // sepolia
      // ====================
      // ====================
      // Deploy MyToken Contract
      // ====================
      // deploying "MyToken" (tx: 0x8553a3629dffd1e7364f40270d70da20e8df515cd0b09695d8d1c38204196c1e)...: deployed at 0x995cbF88F691FCc800E686908566D14f69Bf4c75 with 542474 gas
      // PS D:\Blockchain\ac-hardhat-template>




