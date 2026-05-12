// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleDAO_Fixed_Guard {
    mapping(address => uint256) public balances;

    bool private locked;

    modifier nonReentrant() {
        require(!locked, "Reentrant call blocked");
        locked = true;
        _;
        locked = false;
    }

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount, "Not enough balance");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
