//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSS} from "script/DeployDSS.s.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Handler} from "test/Fuzz/Handler.t.sol";

contract InvariantTest is Test, StdInvariant{

    DeployDSS deployer;
    DecentralizedStableCoin dsc;
    DecentralisedStableCoinSystem dss;
    HelperConfig config;
    
    function setUp() external {
        deployer = new DeployDSS()
        (dsc, dss, config) = deployer.run();
        (,,weth, wbtc,) = config.activeNetworkConfig();
        targetContract(address(dss));
    }
}