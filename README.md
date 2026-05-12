# Ethereum Smart Contract Hack Simulation

이 프로젝트는 Hardhat 로컬 환경에서 과거 이더리움 스마트 컨트랙트 해킹 사례를 재현한 실습입니다.

## 실습 내용

1. DAO Hack - Reentrancy 공격
2. Parity Hack #1 - 초기화 함수 접근제어 실패
3. Parity Hack #2 - 라이브러리 비활성화로 인한 자금 동결

## 실행 환경

- Hardhat
- Solidity ^0.8.20
- ethers.js
- Local Hardhat Network

## DAO Hack

`SimpleDAO.sol`은 ETH를 먼저 보내고 나중에 잔액을 줄이기 때문에 재진입 공격이 가능하다.

공격 결과:

DAO balance before attack: 10.0 ETH  
DAO balance after attack: 0.0 ETH  
Attacker contract balance: 11.0 ETH

수정 코드:

- `SimpleDAO_Fixed_CEI.sol`
- `SimpleDAO_Fixed_Guard.sol`
- `SimpleDAO_Fixed_Pull.sol`

## Parity Hack #1

`initWallet()` 함수가 아무나 호출 가능해서 공격자가 owner를 탈취할 수 있다.

공격 결과:

Wallet1 balance: 5.0 ETH  
Wallet2 balance: 0.0 ETH  
Wallet3 balance: 0.0 ETH

수정 코드:

- `ParityWalletFixed.sol`

## Parity Hack #2

공격자가 라이브러리의 owner를 탈취한 뒤 라이브러리를 사용 불가능하게 만들면, 지갑들이 주요 기능을 실행하지 못하고 자금이 묶인다.

현재 Cancun EVM에서는 `selfdestruct()`가 과거처럼 코드를 삭제하지 않기 때문에, 이 프로젝트에서는 `killed` 플래그로 과거 Parity Hack #2의 효과를 시뮬레이션했다.

공격 결과:

Library killed state: true  
Wallet1 execute failed: funds are frozen  
Wallet1 balance: 5.0 ETH  
Wallet2 balance: 5.0 ETH  
Wallet3 balance: 5.0 ETH

수정 코드:

- `ParityLibraryKillFixed.sol`

## 실행 방법

컴파일:

npx hardhat compile

DAO Hack 실행:

npx hardhat run scripts/dao_attack.ts

Parity Hack #1 실행:

npx hardhat run scripts/parity1_attack.ts

Parity Hack #2 실행:

npx hardhat run scripts/parity2_attack.ts

## 정리

이번 실습을 통해 스마트 컨트랙트 보안에서 실행 순서, 초기화 제어, 접근제어, delegatecall 사용 방식이 중요하다는 것을 확인했다.
