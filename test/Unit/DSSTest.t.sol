//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployDSS} from "script/DeployDSS.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";

contract DSSTest is Test{

    DeployDSS deployer;
    DecentralizedStableCoin dsc;
    DecentralisedStableCoinSystem dss;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    function setUp() public{
        deployer = new DeployDSS();
        (dsc, dss, config) = deployer.run();
        (ethUsdPriceFeed,,weth,,) = config.activeNetworkConfig();
    }

    function getUSDValue() public{
        uint256 ethAmount = 15e18;
        uint256 expectedPrice = 30000e18;
        uint256 actualPrice = dss.getUsdValue(weth, ethAmount);
        assertEq(expectedPrice, actualPrice);
    }
}