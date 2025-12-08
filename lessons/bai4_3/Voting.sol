// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.30;

// contract Voting {

//     address public owner;

//     struct Candidate {
//         string name;
//         uint voteCount;
//     }

//     uint public candidatesCount;

//     mapping(uint => Candidate) public candidates;

//     mapping(address => bool) public hasVoted;

//     event Voted(address indexed voter, uint indexed candidateId);

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only the contract owner can perform this action.");
//         _;
//     }

//     function addCandidate(string memory name) public onlyOwner {
//         candidatesCount++;
//         candidates[candidatesCount] = Candidate(name,0);
//     }

//     function Vote(uint _candidateId) public {
//         address requester = msg.sender;
//         require(!hasVoted[requester],"You have already voted.");
//         require(_candidateId <= candidatesCount && _candidateId > 0,"Invalid candidate ID.");

//         candidates[_candidateId].voteCount++;
//         hasVoted[requester] = true;
//         emit Voted(requester,_candidateId);
//     }
// }