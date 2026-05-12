// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleDAO_Fixed_Pull {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingWithdrawals;

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    // 출금 요청: 바로 ETH를 보내지 않고, 받을 금액만 따로 기록한다
    function requestWithdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");

        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
    }

    // 사용자가 직접 자기 돈을 가져간다
    function claim() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to claim");

        pendingWithdrawals[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
