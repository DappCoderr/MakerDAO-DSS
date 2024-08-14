// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSS} from "script/DeployDSS.s.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OpenInvariantTest is StdInvariant, Test {

    DeployDSS deployerDss;
    DecentralizedStableCoin dsc;
    DecentralisedStableCoinSystem dss;
    HelperConfig config;
    address weth;
    address wbtc;

    function setUp() external {
        deployerDss = new DeployDSS();
        (dsc, dss, config) = deployerDss.run();
        (,,weth, wbtc,) = config.activeNetworkConfig(); 
        targetContract(address(dss));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply(){
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dss));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dss));

        uint256 wethValue = dss.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dss.getUsdValue(wbtc, totalWethDeposited);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}

