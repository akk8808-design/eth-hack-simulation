// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILibraryStatus {
    function killed() external view returns (bool);
}

contract WalletLibraryKillSimulated {
    address public owner;
    bool public killed;

    function initWallet(address _owner) public {
        owner = _owner;
    }

    function execute(address payable to, uint256 amount) public {
        require(msg.sender == owner, "Only owner");
        to.transfer(amount);
    }

    // Cancun 이후 selfdestruct가 코드를 삭제하지 않으므로,
    // 과거 Parity Hack #2의 "라이브러리 사용 불가" 상태를 killed 플래그로 재현한다.
    function kill() public {
        require(msg.sender == owner, "Only owner");
        killed = true;
    }
}

contract ParityWalletUsingSimulatedLibrary {
    address public owner;
    bool public initialized;
    address public walletLibrary;

    constructor(address _walletLibrary, address _owner) {
        walletLibrary = _walletLibrary;

        (bool success, ) = walletLibrary.delegatecall(
            abi.encodeWithSignature("initWallet(address)", _owner)
        );
        require(success, "Initialization failed");
    }

    fallback() external payable {
        // library 자체가 죽은 상태라면 지갑 기능도 멈춘 것으로 처리
        require(
            !ILibraryStatus(walletLibrary).killed(),
            "Library is destroyed"
        );

        (bool success, ) = walletLibrary.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
