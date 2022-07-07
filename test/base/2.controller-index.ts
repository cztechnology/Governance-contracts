import { expect } from "chai";
import { ethers } from "hardhat";
import { Controller__factory, Factory__factory } from "../../typechain";
import Web3 from "Web3";
import { defines } from "../../hardhat.config";
const hre = require("hardhat");
describe("Controller", function () {
  it("Should doploy a platform module", async function () {
    let signers = await hre.ethers.getSigners();
    const web3 = new Web3(hre.network.provider);
    const data = web3.eth.abi.encodeFunctionCall(
      {
        name: "initialize",
        type: "function",
        inputs: [
          {
            type: "address",
            name: "owner",
          },
          {
            type: "string",
            name: "name_",
          },
          {
            type: "string",
            name: "symbol_",
          },
        ],
      },
      [signers[0].address, "NFT", "FNFT"]
    );
    const controller = Controller__factory.connect(defines.controllerAddr, signers[0]);
    await controller.deployModule("NFT", signers[0].address, data);
  });
});
