import "./interfaces/IController.sol";
import "./interfaces/IModule.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IFactory.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

contract Controller is IController, AccessControl, Ownable {
    // bytes32 public constant CONTROLLER_MANAGER_ROLE = keccak256("ControllerManagerRole");
    // bytes32 public constant CONTROLLER_MANAGER_ROLE_AMDMIN = keccak256("ControllerManagerRoleAdmin");
    bytes32 public constant PLATFORM_ROLE = keccak256("PlatformRole");
    bytes32 public constant PLATFORM_ROLE_ADMIN = keccak256("PlatformRoleAdmin");
    string public projectName;
    address public factoryAddr;
    string public avatar;

    mapping(string => address) private modules;
    string[] private allModules;
    ProxyAdmin private _proxyAdmin;
    modifier onlyOwnerOrPlatform() {
        require(owner() == _msgSender() || hasRole(PLATFORM_ROLE, _msgSender()), "no auth");
        _;
    }

    constructor(
        address owner,
        string memory _projectName,
        string memory _avatar
    ) {
        _proxyAdmin = new ProxyAdmin();
        projectName = _projectName;
        avatar = _avatar;
        factoryAddr = _msgSender();
        _transferOwnership(owner);
        _setRoleAdmin(PLATFORM_ROLE, PLATFORM_ROLE_ADMIN);
        _setupRole(PLATFORM_ROLE, _msgSender());
        _setupRole(PLATFORM_ROLE_ADMIN, _msgSender());
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
        for (uint256 i = 0; i < allModules.length; i++) {
            IModule(modules[allModules[i]]).afterControllerTransferOwnership(newOwner);
        }
    }

    function deployModule(
        string calldata moduleName,
        address addr,
        bytes calldata data
    ) external payable override onlyOwnerOrPlatform {
        require(modules[moduleName] == address(0), "module has been deployed");
        address factoryModuleAddr = IFactory(factoryAddr).getPlatformModuleImplement(moduleName);
        if (factoryModuleAddr != address(0)) {
            addr = factoryModuleAddr;
        }
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(addr, address(_proxyAdmin), data);
        modules[moduleName] = address(proxy);
        allModules.push(moduleName);
        emit LogModuleUpdated(address(this), moduleName, address(0), addr);
    }

    function updateModule(
        string calldata moduleName,
        address addr,
        bytes calldata data
    ) external payable override onlyOwnerOrPlatform {
        require(modules[moduleName] != address(0), "module hasn't been deployed");

        address factoryModuleAddr = IFactory(factoryAddr).getPlatformModuleImplement(moduleName);
        if (factoryModuleAddr != address(0)) {
            require(hasRole(PLATFORM_ROLE, _msgSender()), "only platform addr can update platform module");
            addr = factoryModuleAddr;
        }
        require(addr != address(0), "Upgrade Failed: Invalid Implement");
        TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(payable(modules[moduleName]));
        emit LogModuleUpdated(address(this), moduleName, _proxyAdmin.getProxyImplementation(proxy), addr);
        _proxyAdmin.upgradeAndCall{value: msg.value}(proxy, addr, data);
    }

    function getAllModules() external view override returns (string[] memory) {
        return allModules;
    }

    function getModuleAddr(string calldata moduleName) external view override returns (address addr) {
        addr = modules[moduleName];
    }
}
