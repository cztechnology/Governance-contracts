// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

import "../Module/NFT.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract TestNFT is NFT {
    constructor(
        address owner,
        string memory name_,
        string memory symbol_
    ) {
        initialize(owner, name_, symbol_);
    }
}
