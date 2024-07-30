//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSS is Script{

    address[] public tokenAddress;
    address[] public priceFeedAddress;

    function run() external returns(DecentralizedStableCoin, DecentralisedStableCoinSystem) {

        HelperConfig config = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) = config.activeNetworkConfig();

        tokenAddress = [weth,wbtc];
        priceFeedAddress = [wethUsdPriceFeed, wbtcUsdPriceFeed];


        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DecentralisedStableCoinSystem dss = new DecentralisedStableCoinSystem(tokenAddress, priceFeedAddress, address(DecentralizedStableCoin));
        DecentralizedStableCoin.transferOwnership(address(DecentralisedStableCoinSystem));
        vm.stopBroadcast();
        return (DecentralizedStableCoin, DecentralisedStableCoinSystem);
    }
}

