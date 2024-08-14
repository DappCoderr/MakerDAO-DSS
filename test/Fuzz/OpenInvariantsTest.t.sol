// SPDX-License-Identifier:MIT

// Have our invariant aka properties

// What are our invariants?

// Total supply of our DSC tokne shour be less than our collateral value

// Getter view functions should never revert <- evergreen invariant

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSS} from "script/DeployDSS.s.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract OpenInvariantTest is StdInvariant, Test {

    DeployDSS deployerDss;
    DecentralizedStableCoin dsc;
    DecentralisedStableCoinSystem dss;
    HelperConfig config;

    function setUp() external {
        deployerDss = new DeployDSS();
        (dsc, dss, config) = deployerDss.run();
        targetContract(address(dss));
    }
}

