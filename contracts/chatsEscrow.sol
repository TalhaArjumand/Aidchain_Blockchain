// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Minimal interface to call `isBlackListedAddress()` from your Operations contract.
 * Adjust the name/path as needed if you have a full 'Operations.sol' import available.
 */
interface IOperations {
    function isBlackListedAddress(address _addr) external view returns (bool);
}

interface IuniswapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}

interface IquickswapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IWMATIC {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address) external returns(uint);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract chatsEscrow is Ownable {
    // ----------------------------------------------------------
    // External contracts / addresses
    // ----------------------------------------------------------
    IuniswapRouter public uniswapRouter;
    IWMATIC public wmatic;
    IquickswapRouter public quickswapRouter;
    IOperations public operations;        // <-- ADDED: reference to Operations for blacklist checks

    address public immutable uniswapRouterAddress;
    address public immutable wmaticContractAddress;
    address public immutable quickswapRouterAddress;

    // ----------------------------------------------------------
    // Core Mappings
    // ----------------------------------------------------------
    mapping (address => uint256) public funder;           // Track how much stablecoin each user contributed
    mapping (address => bool)    public fundAvailability; // Whether user has funds to withdraw
    mapping (address => bool)    public isFunder;         // Whether user has ever contributed
    mapping (address => bool)    public withdrawalApproval; // Must be set true by admin before user can withdraw

    // Storage for recognized ERC20 tokens by symbol
    mapping (string => address) public erc20Tokens;
    uint256 public erc20TokenCount;

    // ----------------------------------------------------------
    // Campaign State
    // ----------------------------------------------------------
    bool public campaignStatus = true;   // If false, no more funding
    string public campaignName;
    address public defaultStableCoin;

    // ----------------------------------------------------------
    // Events
    // ----------------------------------------------------------
    event efundCampaignMatic(uint256 indexed maticValue, uint256 indexed usdValue);
    event efundCampaignErc20Token(uint256 indexed erc20TokenValue, uint256 indexed usdValue);
    event efundCampaignStableCoin(uint256 indexed usdValue);
    event Debug(string message, address sender, uint256 amount);



    // ----------------------------------------------------------
    // Constructor
    // ----------------------------------------------------------
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor (
        address _uniswapRouterAddress,
        address _wmaticContractAddress,
        address _quickswapRouter,
        string memory _campaignName,
        address _operationsAddress    // <-- ADDED: pass in Operations address
    ){
        require(_uniswapRouterAddress != address(0), "Invalid Uniswap router");
        require(_wmaticContractAddress != address(0), "Invalid WMATIC address");
        require(_quickswapRouter != address(0), "Invalid Quickswap router");
        require(_operationsAddress != address(0), "Invalid Operations address");

        // Store references
        uniswapRouterAddress = _uniswapRouterAddress;
        wmaticContractAddress = _wmaticContractAddress;
        quickswapRouterAddress = _quickswapRouter;

        uniswapRouter = IuniswapRouter(_uniswapRouterAddress);
        wmatic        = IWMATIC(_wmaticContractAddress);
        quickswapRouter = IquickswapRouter(_quickswapRouter);

        // Reference to your Operations contract for blacklist checks
        operations = IOperations(_operationsAddress);

        // Basic campaign info
        campaignName = _campaignName;
    }

    // ----------------------------------------------------------
    // Modifiers
    // ----------------------------------------------------------
    modifier activeCampaign {
        require(campaignStatus, "Campaign is no longer active or has been suspended");
        _;
    }

    // ----------------------------------------------------------
    // Admin Functions (remain onlyOwner)
    // ----------------------------------------------------------
    function adminSignatory(address withdrawer) public virtual onlyOwner returns (bool) {
        withdrawalApproval[withdrawer] = true;
        return true;
    }

    function endCampaign() public virtual onlyOwner returns(bool) {
        campaignStatus = false;
        return true;
    }

    function resumeCampaign() public virtual onlyOwner returns(bool) {
        campaignStatus = true;
        return true;
    }

    function updateDefaultStableCoin(address _defaultStableCoinAddress) public virtual onlyOwner returns (bool){
        defaultStableCoin = _defaultStableCoinAddress;
        return true;
    }

    function updateErc20Token(address _tokenAddress, string calldata _symbol) public virtual onlyOwner returns (bool){
        erc20Tokens[_symbol] = _tokenAddress;
        erc20TokenCount = erc20TokenCount + 1;
        return true;
    }

    // ----------------------------------------------------------
    // Funding Functions
    // ----------------------------------------------------------
    function fundCampaignStableCoin(
        string calldata /*coinSymbol*/, // Not actually used in current logic
        uint256 _amount
    )
        public
        virtual
        activeCampaign
        returns (bool)
    {
        // 1) Check if caller is blacklisted
        require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");
        require(_amount > 0, "You cannot transfer zero amount");

        address coinAddress = defaultStableCoin;
        IERC20Metadata stableCoin = IERC20Metadata(coinAddress);

        bool success = stableCoin.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer not successful");

        funder[msg.sender] += _amount;
        fundAvailability[msg.sender] = true;
        isFunder[msg.sender] = true;
        withdrawalApproval[msg.sender] = false;

        emit efundCampaignStableCoin(_amount);
        return true;
    }


/*
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
*/
  /*  function fundCampaignMatic() public payable virtual activeCampaign returns (bool) {
        require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");

        uint256 amount = msg.value;
        require(amount > 0, "You cannot transfer zero amount");

        emit Debug("Funding Started", msg.sender, amount);

        address stableCoinAddress = defaultStableCoin;

        IuniswapRouter.ExactInputSingleParams memory params = IuniswapRouter.ExactInputSingleParams({
            tokenIn: wmaticContractAddress,
            tokenOut: stableCoinAddress,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp + 300,
            amountIn: amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // Swap MATIC to USDT
        uint256 swappedUSDT = uniswapRouter.exactInputSingle{value: amount}(params);

        emit Debug("Swapped USDT:", msg.sender, swappedUSDT);

        // Store the user as a funder
        funder[msg.sender] += swappedUSDT;
        fundAvailability[msg.sender] = true;
        isFunder[msg.sender] = true;
        withdrawalApproval[msg.sender] = false;

        emit efundCampaignMatic(amount, swappedUSDT);
        return true;
    }
    */



function fundCampaignMatic() public payable virtual activeCampaign returns (bool) {
    require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");

    uint256 amount = msg.value;
    require(amount > 0, "You cannot transfer zero amount");

    emit Debug("Funding Started", msg.sender, amount);

    // 👇 COMMENTING OUT UNISWAP LOGIC FOR GANACHE TESTING
    /*
    address stableCoinAddress = defaultStableCoin;

    IuniswapRouter.ExactInputSingleParams memory params = IuniswapRouter.ExactInputSingleParams({
        tokenIn: wmaticContractAddress,
        tokenOut: stableCoinAddress,
        fee: 3000,
        recipient: address(this),
        deadline: block.timestamp + 300,
        amountIn: amount,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
    });

    // Swap MATIC to USDT
    uint256 swappedUSDT = uniswapRouter.exactInputSingle{value: amount}(params);

    emit Debug("Swapped USDT:", msg.sender, swappedUSDT);

    // Store the user as a funder
    funder[msg.sender] += swappedUSDT;
    */

    // 👇 MOCK LOGIC: Pretend that MATIC is swapped to stablecoin
    funder[msg.sender] += amount; // Simply add MATIC as if it were stablecoin
    fundAvailability[msg.sender] = true;
    isFunder[msg.sender] = true;
    withdrawalApproval[msg.sender] = false;

    // Emit an event with the same value for MATIC & USD
    emit efundCampaignMatic(amount, amount);

    return true;
}

/*
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
*/


    function fundCampaignErc20Token(string calldata coinSymbol, uint256 _amount)
        public
        virtual
        activeCampaign
        returns (bool)
    {
        // 1) Check if caller is blacklisted
        require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");

        require(_amount > 0, "You cannot transfer zero amount");

        address erc20TokenAddress = erc20Tokens[coinSymbol];
        address stableCoinAddress = defaultStableCoin;

        IERC20Metadata erc20Token = IERC20Metadata(erc20TokenAddress);
        bool success = erc20Token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer not successful");

        // Approve Quickswap
        bool approvalSuccess = erc20Token.approve(quickswapRouterAddress, _amount);
        require(approvalSuccess, "Approval not successful");

        address[] memory path1 = new address[](2);
        path1[0] = erc20TokenAddress;
        path1[1] = stableCoinAddress;

        uint256 deadline = block.timestamp + 300;
        uint256[] memory swappedUSDC = quickswapRouter.swapExactTokensForTokens(
            _amount,
            0,
            path1,
            address(this),
            deadline
        );

        funder[msg.sender] += swappedUSDC[1];
        fundAvailability[msg.sender] = true;
        isFunder[msg.sender] = true;
        withdrawalApproval[msg.sender] = false;

        emit efundCampaignErc20Token(_amount, swappedUSDC[1]);
        return true;
    }

    // ----------------------------------------------------------
    // Withdraw Functions
    // ----------------------------------------------------------
    function adminWithdrawFunds(uint256 _amount, address _offRampAddress)
        public
        virtual
        onlyOwner
        returns(bool)
    {
        require(_amount > 0, "You cannot withdraw zero amount");
        address USD = defaultStableCoin;
        IERC20Metadata stableCoin = IERC20Metadata(USD);

        require(stableCoin.balanceOf(address(this)) >= _amount, "Amount requested exceeds token balance");
        bool success = stableCoin.transfer(_offRampAddress, _amount);
        require(success, "Transfer not successful");

        return true;
    }

/*
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
*/

/*
    function withdrawFunds(uint256 _amount) public virtual returns (bool) {
        // 1) Check if caller is blacklisted
        require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");

        require(withdrawalApproval[msg.sender], "You are not authorized to withdraw");
        require(_amount > 0, "You cannot withdraw zero amount");

        uint256 funderBalance = funder[msg.sender];
        require(funderBalance > 0, "You have no funds to withdraw");
        require(fundAvailability[msg.sender], "You have no funds to withdraw");
        require(_amount <= funderBalance, "Amount requested is more than your balance");

        // Subtract from user
        funder[msg.sender] = funderBalance - _amount;
        uint256 remainingBalance = funder[msg.sender];

        // Transfer stablecoin out
        address USD = defaultStableCoin;
        IERC20Metadata stableCoin = IERC20Metadata(USD);

        require(stableCoin.balanceOf(address(this)) >= _amount, "Amount requested exceeds token balance");
        bool success = stableCoin.transfer(msg.sender, _amount);
        require(success, "Transfer not successful");

        // If user drained all, we mark them as no longer having availability
        if (remainingBalance == 0) {
            fundAvailability[msg.sender] = false;
            withdrawalApproval[msg.sender] = false;
        } else {
            // They still have leftover, but we require a new sign-off next time
            withdrawalApproval[msg.sender] = false;
        }

        return true;
    }
*/


function withdrawFunds(uint256 _amount) public virtual returns (bool) {
    // 1) Check if caller is blacklisted
    require(!operations.isBlackListedAddress(msg.sender), "Caller is blacklisted");

    require(withdrawalApproval[msg.sender], "You are not authorized to withdraw");
    require(_amount > 0, "You cannot withdraw zero amount");

    uint256 funderBalance = funder[msg.sender];
    require(funderBalance > 0, "You have no funds to withdraw");
    require(fundAvailability[msg.sender], "You have no funds to withdraw");
    require(_amount <= funderBalance, "Amount requested is more than your balance");

    // Subtract from user
    funder[msg.sender] = funderBalance - _amount;
    uint256 remainingBalance = funder[msg.sender];

    // 🔴 Instead of stablecoin, send back MATIC (for local testing)
    (bool success, ) = msg.sender.call{value: _amount}("");
    require(success, "MATIC transfer failed");

    // If user drained all, we mark them as no longer having availability
    if (remainingBalance == 0) {
        fundAvailability[msg.sender] = false;
        withdrawalApproval[msg.sender] = false;
    } else {
        // They still have leftover, but we require a new sign-off next time
        withdrawalApproval[msg.sender] = false;
    }

    return true;
}

/*
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
**********************************************************************************************************
*/


    // ----------------------------------------------------------
    // View Functions
    // ----------------------------------------------------------
    function getFundAmount(address _funder) public view returns (uint256) {
        return funder[_funder];
    }

    function getFundAvailability(address _funder) public view returns (bool) {
        return fundAvailability[_funder];
    }

    function funderAvailable(address _funder) public view returns (bool) {
        return isFunder[_funder];
    }

    function WithdrawalApprovalStatus(address _funder) public view returns (bool) {
        return withdrawalApproval[_funder];
    }

    function getCampaignStatus() public view returns (bool) {
        return campaignStatus;
    }

    function getTokenBalance() public view returns(uint256) {
        address USD = defaultStableCoin;
        IERC20Metadata stableCoin = IERC20Metadata(USD);
        return stableCoin.balanceOf(address(this));
    }
}
