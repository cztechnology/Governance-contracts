// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface IStrategy {
    function name() external pure returns (string memory);

    function getPriorVotes(
        address ref,
        address account,
        uint256 blockNumber
    ) external view returns (uint96);
}
