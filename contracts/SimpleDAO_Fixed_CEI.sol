// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleDAO_Fixed_CEI {
    mapping(address => uint256) public balances;

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");

        // Effects: 먼저 내부 상태를 바꾼다
        balances[msg.sender] -= amount;

        // Interactions: 그 다음 외부 주소로 ETH를 보낸다
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
