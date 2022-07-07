import "../../Base/interfaces/IModule.sol";

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.4;

interface INFTLogic is IModule {
    struct UserWhitelist {
        address user;
        string[] ipfs;
        uint256 timestamp;
        bool isClaimed;
    }

    function submitWhitelist(bytes[] calldata whitelist, uint256 startClaimTimestamp) external;

    function updateClaimTimestamp(uint256 newTimestamp) external;

    function claimAll() external;

    function getClaimTimestampAllNft(uint256 timestamp) external view returns (UserWhitelist[] memory list);

    function getUserAllNft(address user) external view returns (UserWhitelist[] memory list);

    event LogWhitelistSubmited(UserWhitelist[] whitelist, uint256 startClaimTimestamp);
    event LogClaimTimestampUpdated(uint256 oldTimestamp, uint256 newTimestamp);
    event LogClaimed(address user, string cid, uint256 timestamp);
}
