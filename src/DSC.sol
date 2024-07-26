//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DecentralizedStableCoin is ERC20Burnable, Ownable{

    error DSC_MoreThanZero();
    error DCS_BurnAmountShouldBeGreaterThenBalance();
    error DCS_NotZeroAddress();

    constructor() ERC20("DecentralizedStableCoin", "DSCT") Ownable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {}

    function burn(uint256 amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if(amount <= 0){
            revert DSC_MoreThanZero();
        }
        if(balance <= amount){
            revert DCS_BurnAmountShouldBeGreaterThenBalance();
        }
        super.burn(amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if(_to == address(0)){
            revert DCS_NotZeroAddress();
        }
        if(_amount <= 0){
            revert DSC_MoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
