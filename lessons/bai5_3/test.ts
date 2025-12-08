import { ethers } from "ethers";

async function main() {
  const provider = new ethers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/2W2pZ23QwENfN4wbgBfmVMslzHE7wLh_");

  const abi = [
    "function getCount() public view returns (uint)",
    "function increment() public"
  ];
  const contractAddress = "0x23bB9dCcb4D8c6a316fCF4767948b69021e3775c"; // Contract deploy on sepolia

  const contract = new ethers.Contract(contractAddress, abi, provider);

  const count = await contract.getCount();
  console.log("Current count is:", count.toString());
}

main().catch((error) => {
  console.error("Lỗi:", error.message);
});


// ```
// PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> npx ts-node run.ts bai5_3
// ✅ Đã chạy xong bài: bai5_3
// Current count is: 1
// PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations->
// ```