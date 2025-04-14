// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StudentRegistry} from "../src/StudentRegistry.sol";

interface IStudentRegistryEvents {
    event StudentRegistered(address indexed studentAddress, string name, uint8 age, string className);
}

contract StudentRegistryTest is Test, IStudentRegistryEvents {
    StudentRegistry registry;
    address student1 = address(0x1);
    address student2 = address(0x2);
    address student3 = address(0x3);

    function setUp() public {
        registry = new StudentRegistry();
    }

    function testDeployment() public view {
        assertEq(registry.owner(), address(this), "Owner should be deployer");
    }

    function testRegisterStudent() public {
        vm.prank(student1);
        registry.registerStudent("Alice", 20, "Math");

        (string memory name, uint8 age, string memory className) = registry.getStudent(student1);
        assertEq(name, "Alice");
        assertEq(age, 20);
        assertEq(className, "Math");
    }

    function testCannotRegisterTwice() public {
        vm.prank(student1);
        registry.registerStudent("Alice", 20, "Math");

        vm.expectRevert("Student already registered");
        vm.prank(student1);
        registry.registerStudent("Bob", 22, "Science");
    }

    function testCannotRegisterWithoutName() public {
        vm.expectRevert("Name and class are required");
        vm.prank(student1);
        registry.registerStudent("", 20, "Math");
    }

    function testCannotRegisterWithoutClass() public {
        vm.expectRevert("Name and class are required");
        vm.prank(student1);
        registry.registerStudent("Alice", 20, "");
    }

    function testCannotRegisterWithZeroAge() public {
        vm.expectRevert("Invalid age");
        vm.prank(student1);
        registry.registerStudent("Alice", 0, "Math");
    }

    function testRetrieveUnregisteredStudentFails() public {
        vm.expectRevert("Student not found");
        registry.getStudent(student1);
    }

    function testMultipleStudentsCanRegister() public {
        vm.prank(student1);
        registry.registerStudent("Alice", 20, "Math");
        vm.prank(student2);
        registry.registerStudent("Bob", 22, "Science");

        (string memory name1,,) = registry.getStudent(student1);
        (string memory name2,,) = registry.getStudent(student2);
        assertEq(name1, "Alice");
        assertEq(name2, "Bob");
    }

    function testEventEmittedOnRegistration() public {
        vm.prank(student1);

        vm.expectEmit(true, true, true, true);
        emit StudentRegistered(student1, "Alice", 20, "Math"); // Note the 'registry.' prefix

        registry.registerStudent("Alice", 20, "Math");
    }

    function testDifferentStudentsWithSameNameCanRegister() public {
        vm.prank(student1);
        registry.registerStudent("Charlie", 21, "Physics");
        vm.prank(student2);
        registry.registerStudent("Charlie", 23, "Chemistry");

        (string memory name1, uint8 age1,) = registry.getStudent(student1);
        (string memory name2, uint8 age2,) = registry.getStudent(student2);
        assertEq(name1, "Charlie");
        assertEq(age1, 21);
        assertEq(name2, "Charlie");
        assertEq(age2, 23);
    }

    function testCannotRegisterWithEmptyStrings() public {
        vm.expectRevert("Name and class are required");
        vm.prank(student1);
        registry.registerStudent("", 0, "");
    }

    function testRegisterAndRetrieveMultipleStudents() public {
        vm.prank(student1);
        registry.registerStudent("David", 18, "History");
        vm.prank(student2);
        registry.registerStudent("Emma", 19, "Biology");
        vm.prank(student3);
        registry.registerStudent("Frank", 22, "Geography");

        (string memory name1,,) = registry.getStudent(student1);
        (string memory name2,,) = registry.getStudent(student2);
        (string memory name3,,) = registry.getStudent(student3);

        assertEq(name1, "David");
        assertEq(name2, "Emma");
        assertEq(name3, "Frank");
    }
}
