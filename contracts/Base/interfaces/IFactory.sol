// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface IFactory {
    //projectCount;
    function newProject(
        string calldata projectName,
        address owner,
        string calldata metadata
    ) external returns (address);

    function addPlatformModule(string calldata moduleName, address implement) external;

    function isPlatformModule(string calldata moduleName) external view returns (bool);

    function getPlatformModuleImplement(string calldata moduleName) external view returns (address);

    function getProjectControllerAddr(string calldata projectName) external view returns (address);

    function updateProjectModule(
        string calldata projectName,
        string calldata moduleName,
        address,
        bytes calldata data
    ) external payable;

    event LogNewProject(string projectName, address controllerAddr, string metadata);
    event LogModuleAdded(string moduleName, address implement);
}
