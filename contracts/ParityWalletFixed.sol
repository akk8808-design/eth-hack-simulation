// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletLibraryFixed {
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
}

contract ParityWalletFixed {
    address public owner;
    bool public initialized;
    address public walletLibrary;

    constructor(address _walletLibrary, address _owner) payable {
        walletLibrary = _walletLibrary;

        // 배포 시점에 바로 초기화
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
