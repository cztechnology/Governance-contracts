import "./interfaces/IStrategy.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

contract BalanceOfCompStrategy is IStrategy {
    function name() external pure returns (string memory) {
        return "CompBalanceOf";
    }

    function getPastVotes(
        address ref,
        address account,
        uint256 blockNumber
    ) external view override returns (uint256) {
        return uint256(ERC20VotesComp(ref).getPriorVotes(account, blockNumber));
    }
}
