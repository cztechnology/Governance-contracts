// SPDX-License-Identifier: Apache-2.0
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";

pragma solidity ^0.8.0;

contract TestErc20 is ERC20VotesComp {
    constructor() ERC20("test", "test") ERC20Permit("test") {
        _mint(msg.sender, 2100000000 * 1e18);
    }
}
