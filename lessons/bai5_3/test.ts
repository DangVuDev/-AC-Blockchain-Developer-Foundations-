import { ethers } from "ethers";

async function main() {
  const provider = new ethers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/2W2pZ23QwENfN4wbgBfmVMslzHE7wLh_");

  const privateKey = "a267c5c70821b9382dee*******************b4525461db49c6d542d4d0e";
  const signer = new ethers.Wallet(privateKey, provider);
// Tính năng mới increment();
  const abi = [
    "function getCount() public view returns (uint)",
    "function increment() public"
  ];
  const contractAddress = "0x23bB9dCcb4D8c6a316fCF4767948b69021e3775c"; // Contract deploy on sepolia

  const contract = new ethers.Contract(contractAddress, abi, signer);

  const hashIncrementActionResult = await contract.increment();
  console.log("Action increment hash: ", hashIncrementActionResult.toString());

  const count = await contract.getCount();
  console.log("Current count is:", count.toString());
}

main().catch((error) => {
  console.error("Lỗi:", error.message);
});





