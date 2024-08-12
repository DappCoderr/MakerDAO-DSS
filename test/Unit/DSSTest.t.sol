//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployDSS} from "script/DeployDSS.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract DSSTest is Test{

    DeployDSS deployer;
    DecentralizedStableCoin dsc;
    DecentralisedStableCoinSystem dss;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("Alice");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public{
        deployer = new DeployDSS();
        (dsc, dss, config) = deployer.run();
        (ethUsdPriceFeed,btcUsdPriceFeed,weth,,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    address[] public tokenAddress;
    address[] public priceFeedAddress;

    function testRevertIfTokenLengthDoesNotMatchPricesFeed() public {
        tokenAddress.push(weth);
        priceFeedAddress.push(ethUsdPriceFeed);
        priceFeedAddress.push(btcUsdPriceFeed);

        vm.expectRevert(dss.DSC_TokenAddressAndPriceFeedAddressMustBeSame.selector);
        new DecentralisedStableCoinSystem(tokenAddress, priceFeedAddress, address(dsc));
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dss.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    function getUSDValue() public{
        uint256 ethAmount = 15e18;
        uint256 expectedPrice = 30000e18;
        uint256 actualPrice = dss.getUsdValue(weth, ethAmount);
        assertEq(expectedPrice, actualPrice);
    }

    function testRevertIfCollateralIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dss), AMOUNT_COLLATERAL);
        vm.expectRevert(DecentralisedStableCoinSystem.DSC_NeedMoreThanZero.selector);
        dss.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(dss.DSC_NotAllowedToken.selector);
        dss.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    modifier depositedCollateral(){
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dss), AMOUNT_COLLATERAL);
        dss.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositAndGetCollateralInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 CollateralValueInUsd) = dss.getAccountInfo(USER);

        uint256 expectedTotalDscMinted = 0;
        uint256 expectedCollateralValueInUsd = dss.getTokenAmountFromUsd(weth, CollateralValueInUsd);
        assertEq(CollateralValueInUsd, expectedCollateralValueInUsd);
    }
}