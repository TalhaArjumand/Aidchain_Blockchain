// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;
pragma abicoder v2;

import "./chatsEscrow.sol";

contract chatsEscrowFactory {
    address public owner;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        owner = msg.sender;
    }

    chatsEscrow[] public escrows;
    mapping(uint256 => address) public indexToEscrow; 
    mapping(uint256 => string) public indexToEscrowName;

    event EscrowCreated(uint256 index, address escrowContract);

    modifier onlyOwner {
        require(msg.sender == owner, "Only factory owner can deploy escrow");
        _;
    }

    /**
     * @notice Deploy an instance of chatsEscrow contract
     * @param _uniswapRouterAddress The Uniswap Router address
     * @param _wmaticContractAddress The WMATIC contract address
     * @param _quickswapRouter The Quickswap router address
     * @param _campaignName A string naming this escrow campaign
     * @param _operationsAddress The Operations contract address for blacklist checks
     * @return The newly deployed chatsEscrow contract address
     */
    function deployEscrow(
        address _uniswapRouterAddress,
        address _wmaticContractAddress,
        address _quickswapRouter,
        string memory _campaignName,
        address _operationsAddress
    )
        external
        onlyOwner
        returns (address)
    {
        // Pass all parameters including _operationsAddress to the constructor
        chatsEscrow newEscrow = new chatsEscrow(
            _uniswapRouterAddress,
            _wmaticContractAddress,
            _quickswapRouter,
            _campaignName,
            _operationsAddress
        );

        // 🚀 Assign ownership to the deployer (so they can manage their own escrow)
        newEscrow.transferOwnership(msg.sender);
        // Store in our array
        escrows.push(newEscrow);

        // Map index => contract address, campaign name
        uint256 currentIndex = escrows.length - 1;
        indexToEscrow[currentIndex] = address(newEscrow);
        indexToEscrowName[currentIndex] = _campaignName;

        emit EscrowCreated(currentIndex, address(newEscrow));
        return address(newEscrow);
    }
}
