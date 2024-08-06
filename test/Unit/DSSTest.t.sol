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
    address weth;

    address public USER = makeAddr("Alice");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public{
        deployer = new DeployDSS();
        (dsc, dss, config) = deployer.run();
        (ethUsdPriceFeed,,weth,,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
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
}