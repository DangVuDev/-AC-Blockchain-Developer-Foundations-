import crypto from "crypto";
import { calculateHash } from "./test";

export type Block = {
  index: number;
  timestamp: string;
  transactions: any[];
  previous_hash: string;
  current_hash: string;
};

// ✍️ TODO: Viết hàm tại đây
export function isValidBlock(block: Block): boolean {
  const hash =  calculateHash(block.index, block.timestamp, block.transactions, block.previous_hash)
  return block.current_hash == hash
}
