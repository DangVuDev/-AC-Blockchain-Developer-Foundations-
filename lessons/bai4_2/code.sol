// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.30;



// contract StudentRegistryV2 {

//     struct Student {
//         string name;
//         uint  age;
//         bool isRegistered;
//     }

//     address public owner;

//     event PostNewStudent(address indexed poster, address newStudentAddress, uint256 time);

//     modifier OnlyOwner() {
//         require(owner == msg.sender, "Only owner have post new student");
//         _;
//     }

//     constructor() {
//         owner = msg.sender;
//     }

//     mapping(address => Student) students;

//     function register(address newStudentAddress,string memory name, uint age) public OnlyOwner {
//         require(newStudentAddress != address(0), "Address can't be a emtry address");
//         require(bytes(name).length > 0, "Name cannot be empty.");
//         require(!students[msg.sender].isRegistered, "Student is already registered.");

//         students[msg.sender] = Student({
//             name: name,
//             age: age,
//             isRegistered: true
//         });

//         emit PostNewStudent(msg.sender, newStudentAddress, block.timestamp);
//     }

//     function getStudent(address user) public view returns(Student memory) {
//         require(msg.sender != address(0), "Sender imvalidate address");
//         require(students[user].isRegistered, "User is not register.");
//         return students[user];
//     }

//     function isStudentRegistered(address user) public view returns(bool) {
//         require(msg.sender != address(0), "Sender imvalidate address");
//         return students[user].isRegistered;
//     }




// }