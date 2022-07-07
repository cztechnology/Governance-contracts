import { expect } from "chai";
import { ethers, network } from "hardhat";
import Web3 from "Web3";
import { Controller__factory, Factory__factory } from "../../typechain";

import { defines } from "../../hardhat.config";
const hre = require("hardhat");
describe("Factory", function () {
  it("Should create a controller", async () => {
    let signers = await hre.ethers.getSigners();
    const projectName = "first project";
    const moduleName = "NFT";
    const web3 = new Web3(hre.network.provider);
    if (!defines.factoryAddr) {
      const factory = await hre.ethers.getContractFactory("Factory");
      await network.provider.send("hardhat_setBalance", [
        signers[0].address,
        defines.Unit.Ether.mul(100)._hex.replace(/0x0+/, "0x"),
      ]);
      let f = await factory.deploy();
      await f.newProject(projectName, signers[0].address, "test.png");
      const controllerAddr = await f.getProjectControllerAddr(projectName);
      const controller = Controller__factory.connect(controllerAddr, signers[0]);
      console.log(f.address, controller.address);
      defines.factoryAddr = f.address;
      defines.controllerAddr = controller.address;
      // f = factory;
      const newProjectName = await controller.projectName();
      expect(newProjectName == projectName, "projectName should be same");
      const moduleFactory = await hre.ethers.getContractFactory("NFT");
      const module = await moduleFactory.deploy();
      // console.log(module.address);
      await f.addPlatformModule(moduleName, module.address);
      // await f.updateProjectModule(projectName, moduleName, module.address, [], { gasLimit: 3000000 });
    }
  });
});
