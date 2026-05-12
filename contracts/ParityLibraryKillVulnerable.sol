// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletLibraryKillVulnerable {
    address public owner;

    // 취약점 1: 라이브러리도 아무나 초기화 가능
    function initWallet(address _owner) public {
        owner = _owner;
    }

    function execute(address payable to, uint256 amount) public {
        require(msg.sender == owner, "Only owner");
        to.transfer(amount);
    }

    // 취약점 2: owner가 된 사람이 라이브러리 자체를 제거할 수 있음
    function kill() public {
        require(msg.sender == owner, "Only owner");

        // 과거 Parity Hack #2의 핵심 동작을 재현하기 위한 코드
        selfdestruct(payable(msg.sender));
    }
}

contract ParityWalletUsingLibrary {
    address public owner;
    address public walletLibrary;

    constructor(address _walletLibrary, address _owner) payable {
        walletLibrary = _walletLibrary;

        // 각 지갑은 배포될 때 정상 owner를 설정
        (bool success, ) = walletLibrary.delegatecall(
            abi.encodeWithSignature("initWallet(address)", _owner)
        );
        require(success, "Initialization failed");
    }

    fallback() external payable {
        (bool success, ) = walletLibrary.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
