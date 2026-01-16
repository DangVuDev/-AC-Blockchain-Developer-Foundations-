import { ethers } from "ethers";

async function main() {
  const provider = new ethers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/2W2pZ23QwENfN4wbgBfmVMslzHE7wLh_");

  const privateKey = "a267c5c70821b9382dee97afcf45be4f57246ff6db4525461db49c6d542d4d0e";
  const signer = new ethers.Wallet(privateKey, provider);
// Tính năng mới increment();
  const abi = [
    "function getCount() public view returns (uint)",
    "function increment() public"
  ];
  const contractAddress = "0x725E62364CF6024bd1b681AB779692Eb8A2Df066"; // Contract deploy on sepolia

  const contract = new ethers.Contract(contractAddress, abi, signer);

  const Currentcount = await contract.getCount();
  console.log("Current count is:", Currentcount.toString());

  const tx = await contract.increment();
  const receipt = await tx.wait();
  console.log("Transaction receipt:", receipt);
  console.log("Increment action mined in tx:", JSON.stringify(tx));

  const count = await contract.getCount();
  console.log("Current count is:", count.toString());
}

main().catch((error) => {
  console.error("Lỗi:", error.message);
});





