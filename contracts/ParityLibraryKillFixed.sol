// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletLibraryKillFixed {
    address public owner;
    bool public initialized;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function initWallet(address _owner) public {
        require(!initialized, "Already initialized");
        owner = _owner;
        initialized = true;
    }

    function execute(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
    }

    // 수정 핵심:
    // kill(), selfdestruct() 같은 라이브러리 제거 함수는 아예 두지 않는다.
}

contract ParityWalletUsingFixedLibrary {
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
        (bool success, ) = walletLibrary.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
