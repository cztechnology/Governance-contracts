import * as dotenv from "dotenv";

import { extendEnvironment, HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import { ethers } from "ethers";
dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      accounts: {
        accountsBalance: "200000000000000000000001",
      },
    },
    localhost: {
      url: "HTTP://127.0.0.1:8545",
      accounts: [...(process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [])],
    },
    gpnode: {
      url: process.env.GPNODE_URL || "",
      accounts: [...(process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [])],
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkby: {
      url: process.env.RINKBY_URL || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: process.env.GOERLI_URL || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  mocha: {
    timeout: 76800000,
  },
};

export default config;

export const defines = {
  Unit: {
    Wei: ethers.BigNumber.from("1"),
    GWei: ethers.BigNumber.from("1000000000"),
    Ether: ethers.BigNumber.from("1000000000000000000"),
  },
  Id: {
    Buyer: 0,
    Treasury: 1,
    Platform: 2,
    Buyer1: 4,
    Buyer2: 5,
    Buyer3: 6,
    Default: 7,
  },
  controllerAddr: "",
  factoryAddr: "",
};
