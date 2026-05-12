// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletLibrary {
    address public owner;

    // 취약점: 이미 초기화되었는지 확인하지 않음
    function initWallet(address _owner) public {
        owner = _owner;
    }

    function execute(address payable to, uint256 amount) public {
        require(msg.sender == owner, "Only owner");
        to.transfer(amount);
    }
}

contract ParityWalletVulnerable {
    address public owner;
    address public walletLibrary;

    constructor(address _walletLibrary) payable {
        walletLibrary = _walletLibrary;
    }

    // delegatecall을 통해 WalletLibrary의 함수를 실행
    fallback() external payable {
        (bool success, ) = walletLibrary.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
