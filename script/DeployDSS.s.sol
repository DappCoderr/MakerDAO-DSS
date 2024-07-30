//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";

contract DeployDSS is Script{
    function run() external returns(DecentralizedStableCoin, DecentralisedStableCoinSystem) {
        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DecentralisedStableCoinSystem dss = new DecentralisedStableCoinSystem();
        vm.stopBroadcast();
        return (dsc, dss);
    }
}

