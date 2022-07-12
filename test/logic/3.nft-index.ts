import { expect } from "chai";
import { ethers, network } from "hardhat";
import Web3 from "Web3";

import { defines } from "../../hardhat.config";
import { Controller__factory, Factory__factory, NFT__factory } from "../../typechain";
const Id = defines.Id;
const Ether = defines.Unit.Ether;
const hre = require("hardhat");
const delay = 100;
describe("Greeter", function () {
  it("claim nft 数量测试", async () => {
    let signers = await ethers.getSigners();
    let nftAdmin = signers[0];
    let other = signers[1];
    let buyer = signers[0];

    // await network.provider.send("evm_increaseTime", [-86400 * 26]);
    // await network.provider.send("evm_mine");
    const controller = Controller__factory.connect(defines.controllerAddr, signers[0]);
    const Addr = await controller.getModuleAddr("NFT");
    await network.provider.send("hardhat_setBalance", [nftAdmin.address, Ether.mul(100)._hex.replace(/0x0+/, "0x")]);
    await network.provider.send("hardhat_setBalance", [buyer.address, Ether.mul(100)._hex.replace(/0x0+/, "0x")]);
    await network.provider.send("hardhat_setBalance", [other.address, Ether.mul(100)._hex.replace(/0x0+/, "0x")]);
    let nttAbi = await NFT__factory.connect(Addr, buyer);
    let i = 0;
    let addWhiteListAndClaimed = async (data: any, count: number) => {
      let balanceBefore = await nttAbi.balanceOf(buyer.address);
      const deadline = (await ethers.provider.getBlock("latest")).timestamp + delay + i;

      let tx = await nttAbi.connect(nftAdmin).submitWhitelist(data, deadline);
      await tx.wait();
      await network.provider.send("evm_increaseTime", [delay + i++]);
      await network.provider.send("evm_mine");
      let tx1 = await nttAbi.connect(buyer).claimAll({ gasLimit: 30000000 });
      await tx1.wait();
      let tx2 = await nttAbi.connect(other).claimAll({ gasLimit: 30000000 });
      await tx2.wait();
      let balanceAfter = await nttAbi.balanceOf(buyer.address);
      expect(
        balanceAfter.eq(balanceBefore.add(count)),
        `claim 前:${balanceBefore.toNumber()} 后:${balanceAfter.toNumber()} dlen ${count}`
      ).to.true;
    };
    let datas = [];
    let ipfsUri = "ipfs://bafybeibwzifw52ttrkqlikfzext5akxu7lz4xiwjgwzmqcpdzmp3n5vnbe";
    datas.push(
      ethers.utils.defaultAbiCoder.encode(["tuple(address,string[],uint256,bool)"], [[buyer.address, [ipfsUri], 0, false]])
    );
    await addWhiteListAndClaimed(datas, 1);
    datas = [];
    datas.push(
      ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,string[],uint256,bool)"],
        [[buyer.address, [ipfsUri, ipfsUri], 0, false]]
      )
    );
    await addWhiteListAndClaimed(datas, 2);
    datas = [];
    datas.push(
      ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,string[],uint256,bool)"],
        [[buyer.address, [ipfsUri, ipfsUri], 0, false]]
      )
    );
    datas.push(
      ethers.utils.defaultAbiCoder.encode(["tuple(address,string[],uint256,bool)"], [[buyer.address, [ipfsUri], 0, false]])
    );
    await addWhiteListAndClaimed(datas, 3);
  });

  it("ntt 转账测试", async () => {
    await network.provider.send("evm_mine");
    let signers = await ethers.getSigners();
    let nftAdmin = signers[0];
    let platform = signers[Id.Platform];
    let buyer = signers[0];
    const controller = Controller__factory.connect(defines.controllerAddr, signers[0]);
    const Addr = await controller.getModuleAddr("NFT");
    await network.provider.send("hardhat_setBalance", [nftAdmin.address, Ether.mul(100)._hex.replace(/0x0+/, "0x")]);
    await network.provider.send("hardhat_setBalance", [buyer.address, Ether.mul(100)._hex.replace(/0x0+/, "0x")]);
    let nttAbi = await NFT__factory.connect(Addr, buyer);
    let addWhiteListAndClaimed = async (data: any, count: number) => {
      let balanceBefore = await nttAbi.balanceOf(buyer.address);
      let tx = await nttAbi
        .connect(nftAdmin)
        .submitWhitelist(data, (await ethers.provider.getBlock("latest")).timestamp + delay);
      await tx.wait();
      await network.provider.send("evm_increaseTime", [delay]);
      await network.provider.send("evm_mine");
      let tx1 = await nttAbi.connect(buyer).claimAll();
      await tx1.wait();
      let balanceAfter = await nttAbi.balanceOf(buyer.address);
      expect(
        balanceAfter.eq(balanceBefore.add(count)),
        `claim 前:${balanceBefore.toNumber()} 后:${balanceAfter.toNumber()} dlen ${count}`
      ).to.true;
    };
    let datas = [];
    let ipfsUri = "ipfs://bafybeibwzifw52ttrkqlikfzext5akxu7lz4xiwjgwzmqcpdzmp3n5vnbe";
    datas.push(
      ethers.utils.defaultAbiCoder.encode(["tuple(address,string[],uint256,bool)"], [[buyer.address, [ipfsUri], 0, false]])
    );
    await addWhiteListAndClaimed(datas, 1);
    await expect(nttAbi.transferFrom(buyer.address, nftAdmin.address, 0), "NTT 不可转账").to.reverted;
  });
});
