// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.30;



// contract StudentRegistry {

//     struct Student {
//         string name;
//         uint  age;
//         bool isRegistered;
//     }

//     mapping(address => Student) students;

//     function register(string memory name, uint age) public {
//         require(bytes(name).length > 0, "Name cannot be empty.");
//         require(!students[msg.sender].isRegistered, "Student is already registered.");

//         students[msg.sender] = Student({
//             name: name,
//             age: age,
//             isRegistered: true
//         });

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