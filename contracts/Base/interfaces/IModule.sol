// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface IModule {
    function getControllerAddr() external view returns (address addr);

    function afterControllerTransferOwnership(address newOwner) external;
}
