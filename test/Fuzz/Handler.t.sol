// Handler is going to narrow down the way we call our functions

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";

contract Handler is Test{

    DecentralisedStableCoinSystem dss;
    DecentralizedStableCoin dsc;

    constructor(DecentralisedStableCoinSystem _dss, DecentralizedStableCoin _dsc){
        dss = _dss;
        dsc = _dsc;
    }

    function depositHandler(address collateral, uint256 amountCollateral) public {
        dss.depositCollateral(collateral, amountCollateral);
    }
}