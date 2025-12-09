# Contract 

```
     // SPDX-License-Identifier: MIT
      pragma solidity ^0.8.28;

      contract Counter {
          uint public count;

          function increment() public {
              count += 1;
          }

          function getCount() public view returns (uint) {
              return count;
          }
      }
```
---

# Test script
```
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
```

--- 

# Result

```
    PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> npx ts-node run.ts bai5_3
      ✅ Đã chạy xong bài: bai5_3
      Action increment hash:  [object Object]
      Current count is: 1
      PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> npx ts-node run.ts bai5_3
      ✅ Đã chạy xong bài: bai5_3
      Action increment hash:  [object Object]
      Current count is: 2
      PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> npx ts-node run.ts bai5_3
      ✅ Đã chạy xong bài: bai5_3
      Action increment hash:  [object Object]
      Current count is: 3
      PS C:\Users\vuvan\OneDrive\Documents\GitHub\-AC-Blockchain-Developer-Foundations-> 
```
