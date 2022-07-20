// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

import "./interfaces/INFTLogic.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

contract NFT is INFTLogic, ERC721URIStorageUpgradeable, AccessControlEnumerableUpgradeable {
    bytes32 public constant WHITELIST_ROLE = keccak256("WhitelistRole");
    bytes32 public constant WHITELIST_ROLE_ADMIN = keccak256("WhitelistRoleAdmin");
    address private controllerAddr;

    uint256 public currentTimestamp;
    uint256[] public timestampHistory;
    UserWhitelist[] public currentWhitelist;
    UserWhitelist[] public claimableList;

    uint256 private totalSupply;

    // mapping(bytes => int256) deadlineMaps;
    function initialize(
        address owner,
        string memory name_,
        string memory symbol_
    ) public initializer {
        __ERC721_init(name_, symbol_);
        _setRoleAdmin(WHITELIST_ROLE, WHITELIST_ROLE_ADMIN);
        _setupRole(WHITELIST_ROLE_ADMIN, owner);
        _setupRole(WHITELIST_ROLE, owner);
        controllerAddr = _msgSender();
    }

    function getControllerAddr() public view override returns (address addr) {
        addr = controllerAddr;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert(" nft is untransferable");
    }

    function submitWhitelist(bytes[] calldata whitelist, uint256 startClaimTimestamp)
        external
        override
        onlyRole(WHITELIST_ROLE)
    {
        require(
            block.timestamp > currentTimestamp || currentTimestamp == startClaimTimestamp,
            "can not submit a new list,please use updateClaimTimestamp"
        );
        if (startClaimTimestamp > currentTimestamp) {
            for (uint256 i = 0; i < currentWhitelist.length; i++) {
                claimableList.push(currentWhitelist[i]);
            }
            currentTimestamp = startClaimTimestamp;
            timestampHistory.push(currentTimestamp);
        }
        require(startClaimTimestamp > block.timestamp, "start claim timestamp must behind block timestamp");
        delete currentWhitelist;
        for (uint256 i = 0; i < whitelist.length; i++) {
            UserWhitelist memory info = abi.decode(whitelist[i], (UserWhitelist));
            info.isClaimed = false;
            info.timestamp = startClaimTimestamp;
            currentWhitelist.push(info);
        }
        emit LogWhitelistSubmited(currentWhitelist, startClaimTimestamp);
    }

    function updateClaimTimestamp(uint256 newTimestamp) external override onlyRole(WHITELIST_ROLE) {
        require(currentTimestamp > block.timestamp, "can not update,please submit");
        emit LogClaimTimestampUpdated(currentTimestamp, newTimestamp);
        currentTimestamp = newTimestamp;
    }

    function claimAll() external override {
        address user = _msgSender();
        if (currentWhitelist.length > 0) {
            if (currentWhitelist[0].timestamp <= block.timestamp) {
                for (uint256 i = 0; i < currentWhitelist.length; i++) {
                    if (currentWhitelist[i].user == user && !currentWhitelist[i].isClaimed) {
                        currentWhitelist[i].isClaimed = true;
                        for (uint256 j = 0; j < currentWhitelist[i].ipfs.length; j++) {
                            _mint(user, totalSupply);
                            _setTokenURI(totalSupply++, currentWhitelist[i].ipfs[j]);
                            emit LogClaimed(user, currentWhitelist[i].ipfs[j], currentWhitelist[i].timestamp);
                        }
                    }
                }
            }
        }
        for (uint256 i = 0; i < claimableList.length; i++) {
            if (claimableList[i].user == user && !claimableList[i].isClaimed) {
                claimableList[i].isClaimed = true;
                for (uint256 j = 0; j < claimableList[i].ipfs.length; j++) {
                    _mint(user, totalSupply);
                    _setTokenURI(totalSupply++, claimableList[i].ipfs[j]);
                    emit LogClaimed(user, claimableList[i].ipfs[j], claimableList[i].timestamp);
                }
            }
        }
    }

    function getClaimTimestampAllNft(uint256 timestamp) external view override returns (UserWhitelist[] memory list) {
        uint256 k = 0;
        for (uint256 i = 0; i < currentWhitelist.length; i++) {
            if (currentWhitelist[i].timestamp == timestamp) {
                list[k++] = currentWhitelist[i];
            }
        }
        for (uint256 i = 0; i < claimableList.length; i++) {
            if (claimableList[i].timestamp == timestamp) {
                list[k++] = claimableList[i];
            }
        }
    }

    function getUserAllNft(address user) external view override returns (UserWhitelist[] memory list) {
        uint256 k = 0;
        for (uint256 i = 0; i < currentWhitelist.length; i++) {
            if (currentWhitelist[i].user == user) {
                list[k++] = currentWhitelist[i];
            }
        }
        for (uint256 i = 0; i < claimableList.length; i++) {
            if (claimableList[i].user == user) {
                list[k++] = claimableList[i];
            }
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlEnumerableUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return
            ERC721Upgradeable.supportsInterface(interfaceId) ||
            AccessControlEnumerableUpgradeable.supportsInterface(interfaceId);
    }

    fallback() external {}

    function afterControllerTransferOwnership(address newOwner) external override {
        require(msg.sender == getControllerAddr(), "no auth!");
        _revokeRole(WHITELIST_ROLE_ADMIN, getRoleMember(WHITELIST_ROLE_ADMIN, 0));
        _setupRole(WHITELIST_ROLE_ADMIN, newOwner);
        _setupRole(WHITELIST_ROLE, newOwner);
    }
}
