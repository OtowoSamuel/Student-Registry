// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract StudentRegistry {
    struct Student {
        string name;
        uint8 age;
        string className;
    }

    address public owner;
    mapping(address => Student) private students;
    mapping(address => bool) private isRegistered;

    event StudentRegistered(address indexed studentAddress, string name, uint8 age, string className);

    constructor() {
        owner = msg.sender;
    }

    function registerStudent(string memory _name, uint8 _age, string memory _className) external {
        require(!isRegistered[msg.sender], "Student already registered");
        require(bytes(_name).length > 0 && bytes(_className).length > 0, "Name and class are required");
        require(_age > 0, "Invalid age");

        students[msg.sender] = Student(_name, _age, _className);
        isRegistered[msg.sender] = true;

        emit StudentRegistered(msg.sender, _name, _age, _className);
    }

    function getStudent(address _student) external view returns (string memory, uint8, string memory) {
        require(isRegistered[_student], "Student not found");
        Student memory s = students[_student];
        return (s.name, s.age, s.className);
    }
}
