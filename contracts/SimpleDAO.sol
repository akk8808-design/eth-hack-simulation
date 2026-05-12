// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleDAO {
    mapping(address => uint256) public balances;

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");

        // 취약점: 잔액을 줄이기 전에 ETH를 먼저 보냄
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // 과거 Solidity처럼 언더플로우 검사를 꺼서 DAO Hack을 재현
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
