// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

/**
 * @title IchatsEscrow
 * @notice Interface matching the updated chatsEscrow.sol contract
 */
interface IchatsEscrow {

    // -----------------------------------------------------
    // View (read-only) Functions
    // -----------------------------------------------------
    function getFundAmount(address _funder) external view returns (uint256);

    function getFundAvailability(address _funder) external view returns (bool);

    function funderAvailable(address _funder) external view returns (bool);

    function WithdrawalApprovalStatus(address _funder) external view returns (bool);

    function getCampaignStatus() external view returns (bool);

    function getTokenBalance() external view returns (uint256);

    // -----------------------------------------------------
    // Admin & Campaign Management
    // -----------------------------------------------------
    function adminSignatory(address withdrawer) external returns (bool);

    function endCampaign() external returns (bool);

    function resumeCampaign() external returns (bool);

    function updateDefaultStableCoin(address _defaultStableCoinAddress) external returns (bool);

    function updateErc20Token(address _tokenAddress, string calldata _symbol) external returns (bool);

    // -----------------------------------------------------
    // Funding / Withdrawing
    // -----------------------------------------------------
    // The escrow accepts stablecoin, MATIC, or arbitrary ERC20. 
    // They each return bool to signal success.

    function fundCampaignStableCoin(string calldata coinSymbol, uint256 _amount) external returns (bool);

    function fundCampaignMatic() external payable returns (bool);

    function fundCampaignErc20Token(string calldata coinSymbol, uint256 _amount) external returns (bool);

    function adminWithdrawFunds(uint256 _amount, address _offRampAddress) external returns (bool);

    function withdrawFunds(uint256 _amount) external returns (bool);
}
