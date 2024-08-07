//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DSC.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DecentralisedStableCoinSystem is ReentrancyGuard {

    /////////////////////////////////////////////////////
    // ERRORS /////////
    /////////////////////////////////////////////////////
    error DSC_NeedMoreThanZero();
    error DSC_TokenAddressAndPriceFeedAddressMustBeSame();
    error DSC_NotAllowedToken();
    error DSC_TransferFail();
    error DSC_HealthFactorIsBelowMinimum();
    error DSC_MintFailed();

    /////////////////////////////////////////////////////
    // STATE VARIABLES /////////
    /////////////////////////////////////////////////////
    mapping (address token => address priceFeed) private s_priceFeed;
    mapping (address user => mapping (address token => uint amount)) private s_collateralDeposited;
    mapping (address user => uint256 amount) private s_DscMinted;

    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;
   
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISIION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    /////////////////////////////////////////////////////
    // EVENTS /////////
    /////////////////////////////////////////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);
    event CollateralRedeem(address user, address collateralToken, uint256 tokenAmount);
    /////////////////////////////////////////////////////
    // MODIFIERS /////////
    /////////////////////////////////////////////////////
    modifier moreThanZero(uint256 amount) {
        if(amount <= 0){
            revert DSC_NeedMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token){
        if(s_priceFeed[token] == address(0)){
            revert DSC_NotAllowedToken();
        }
        _;
    }

    constructor(address[] memory tokenAddress, address[] memory priceFeedAddress, address dscTokenAddress){
        if(tokenAddress.length != priceFeedAddress.length){
            revert DSC_TokenAddressAndPriceFeedAddressMustBeSame();
        }
        for (uint i = 0; i < tokenAddress.length; i++) {
            s_priceFeed[tokenAddress[i]] = priceFeedAddress[i];
            s_collateralTokens.push(tokenAddress[i]);
        }
        i_dsc = DecentralizedStableCoin(dscTokenAddress);
    }

    function depositCollateralAndMintDSC(address collateralToken, uint256 collateralAmount, uint256 amontDscToMint) external{
        depositCollateral(collateralToken, collateralAmount);
        mintDSC(amontDscToMint);
    }

    function depositCollateral(address collateralTokenAddress, uint256 collateralAmount) 
    public 
    moreThanZero(collateralAmount)
    isAllowedToken(collateralTokenAddress)
    nonReentrant
    {
        s_collateralDeposited[msg.sender][collateralTokenAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, collateralTokenAddress, collateralAmount);
        bool success = IERC20(collateralTokenAddress).transferFrom(msg.sender, address(this), collateralAmount);
        if(!success){
            revert DSC_TransferFail();
        }
    }

    function redeemCollateralForDSC() external{}

    function redeemCollateral(address collateralTokenAddress, uint256 collateralAmount) 
        external 
        moreThanZero(collateralAmount) 
        nonReentrant()
    {
        s_collateralDeposited[msg.sender][collateralTokenAddress] -= collateralAmount;
        emit CollateralRedeem(msg.sender, collateralTokenAddress, collateralAmount);
        bool sucess = IERC20(collateralTokenAddress).transfer(msg.sender, collateralAmount);
        if(!sucess){
            revert DSC_TransferFail();
        }
    }

    function mintDSC(uint256 amountDscToMint) public {
        s_DscMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if(!minted){
            revert DSC_MintFailed();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDSC() external{}

    // This function is called to remove other people position to save the protocol.
    function liquidate() external{}

    // This function will return how healthy people are.
    function getHealthFactor() external view{}

    /////////////////////////////////////////////////////
    // Private & Internal View & Pure Functions /////////
    /////////////////////////////////////////////////////

    function _getAccountInformation(address user) private view returns(uint256, uint256){
        uint256 totalDscMinted = s_DscMinted[user];
        uint256 collateralValueInUsd = getAccountCollateralValue(user);
        return (totalDscMinted, collateralValueInUsd);
    }

    // If the healthfactor is less than 1, then your positon will be get liquidated.
    function _healthfactor(address user) private view returns(uint256){
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISIION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthfactor(user);
        if(userHealthFactor < MIN_HEALTH_FACTOR){
            revert DSC_HealthFactorIsBelowMinimum();
        }

    }

    /////////////////////////////////////////////////////
    // Public & External View & Pure Functions /////////
    /////////////////////////////////////////////////////

    function getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUsd){
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
    }

    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        // We take the ETH/USD price from chainlink AggregatorV3Interface
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed[token]);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}