// Handler is going to narrow down the way we call our functions

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DSC.sol";
import {DecentralisedStableCoinSystem} from "src/DSS.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test{

    DecentralisedStableCoinSystem dss;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    constructor(DecentralisedStableCoinSystem _dss, DecentralizedStableCoin _dsc){
        dss = _dss;
        dsc = _dsc;

        address[] memory collateralTokens = dss.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    function depositHandler(uint256 collateralSeed, uint256 amountCollateral) public {
        // dss.depositCollateral(collateral, amountCollateral);
    }

    function mintDsc(uint256 amount) public{
        amount = bound(amount, 1, MAX_DEPOSIT_SIZE);
    }

    

    function _getCollateralSeed(uint256 colateralSeed) public{

    }
}