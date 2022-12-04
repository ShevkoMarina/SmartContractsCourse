// SPDX-License-Identifier; MIT
pragma solidity ^0.8.4;

contract AddigNumbersContract {
    int a;
    int b;
    int c;

    function add(int num_1, int num_2) public {
        a = num_1;
        b = num_2;
        c = a + b;
    }

    function getSum() public view returns (int) {
        return c;
    }
}