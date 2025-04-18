// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChatsNFT {
    function getTokenURI(uint256 tokenId) external view returns (string memory);
    function getName() external view returns (string memory);
    function getSymbol() external view returns (string memory);
    function getOwner(uint256 tokenId) external view returns (address);
    function getBalance(address owner) external view returns (uint256);

    function mintNFT(address recipient, string[] memory tokenURI) external returns (bool);
    function burnNFT(uint256[] memory NFTtokenId) external returns (bool);

    function safeTransferFrom_(address from, address to, uint256 tokenId) external returns (bool);
    function transferFrom_(address from, address to, uint256 tokenId) external returns (bool);
    function approve_(address to, uint256 tokenId) external returns (bool);
    function getApproved_(uint256 tokenId) external view returns (bool);
    function setApprovalForAll_(address operator, bool approved) external returns (bool);
    function isApprovedForAll_(address owner, address operator) external view returns (bool);

    // Renamed the second "safeTransferFrom_" to avoid collision:
    function safeTransferFromWithData(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external returns (bool);

    function getTotalMinted() external view returns (uint256);

    // Must NOT be "view" because it modifies state in the implementation
    function setNFTLimit(uint256 limit) external returns (bool);
}
