import "./interfaces/IFactory.sol";
import "./Controller.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

contract Factory is IFactory, Ownable {
    mapping(string => address) projectMap;
    mapping(string => address) platformModule;
    string[] public allModule;

    function newProject(
        string calldata projectName,
        address owner,
        string calldata avatar
    ) external override returns (address) {
        require(projectMap[projectName] == address(0), "project already exist");
        Controller controller = new Controller(owner, projectName, avatar);
        projectMap[projectName] = address(controller);
        emit LogNewProject(projectName, address(controller), avatar);
        return address(controller);
    }

    function addPlatformModule(string calldata moduleName, address implement) external onlyOwner {
        if (platformModule[moduleName] == address(0)) {
            allModule.push(moduleName);
        }
        platformModule[moduleName] = implement;
        emit LogModuleAdded(moduleName, implement);
    }

    function getPlatformModuleImplement(string calldata moduleName) external view returns (address) {
        return platformModule[moduleName];
    }

    function isPlatformModule(string calldata moduleName) external view returns (bool) {
        return platformModule[moduleName] != address(0);
    }

    function updateProjectModule(
        string calldata projectName,
        string calldata moduleName,
        address,
        bytes calldata data
    ) external payable onlyOwner {
        IController(getProjectControllerAddr(projectName)).updateModule(moduleName, address(0), data);
    }

    function getProjectControllerAddr(string calldata projectName) public view override returns (address addr) {
        addr = projectMap[projectName];
    }
}
