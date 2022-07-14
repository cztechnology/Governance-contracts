import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface IController is IAccessControl {
    function deployModule(
        string calldata moduleName,
        address addr,
        bytes calldata data
    ) external payable;

    function updateModule(
        string calldata moduleName,
        address addr,
        bytes calldata data
    ) external payable;

    function setMetadata(string memory newMetadata) external;

    function getModuleAddr(string calldata moduleName) external view returns (address addr);

    // function addExistedModule(string calldata moduleName, address addr)
    //     external
    //     payable;
    function getAllModules() external view returns (string[] memory);

    event LogModuleUpdated(address controllerAddr, string moduleName, address oldAddr, address newAddr);
    event LogMetedataSet(string newMetadata);
}
