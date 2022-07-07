import "./interfaces/IStrategy.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

contract BalanceOfStrategy is IStrategy {
    function name() external pure returns (string memory) {
        return "BalanceOf";
    }

    function getPriorVotes(
        address ref,
        address account,
        uint256 blockNumber
    ) external view override returns (uint96) {
        return ERC20VotesComp(ref).getPriorVotes(account, blockNumber);
    }
}
