// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {StableCoin} from "../../src/StableCoin.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {console} from "../../lib/forge-std/src/console.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StableCoinTest is Test {
    StableCoin sc;

    address alice = makeAddr("alice");

    function setUp() public {
        sc = new StableCoin();
    }

    function test_Mint() public {
        assertEq(sc.balanceOf(alice), 0);
        sc.mint(alice, 100);
        assertEq(sc.balanceOf(alice), 100);
    }

    function test_OnlyOwnerCanMint() public {
        assertEq(sc.balanceOf(alice), 0);

        sc.mint(alice, 100);
        assertEq(sc.balanceOf(alice), 100);

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        sc.mint(alice, 100);
        vm.stopPrank();
    }

    function test_Burn() public {
        assertEq(sc.balanceOf(alice), 0);

        sc.mint(alice, 100);
        assertEq(sc.balanceOf(alice), 100);

        vm.startPrank(alice);
        sc.burn(50);
        assertEq(sc.balanceOf(alice), 50);
        vm.stopPrank();
    }

    function test_NameAndSymbol() public view {
        assertEq(sc.name(), "StableCoin");
        assertEq(sc.symbol(), "SC");
    }

    function test_Owner() public {
        assertEq(sc.owner(), address(this));
        sc.transferOwnership(alice);
        assertEq(sc.owner(), alice);
    }
}
