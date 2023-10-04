//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {UtopiaFactory} from "../src/UtopiaFactory.sol";
import {UtopiaPair} from "../src/UtopiaPair.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {IUtopiaPair} from "../src/interface/IUtopiaPair.sol";

contract TestUtopiaPair is Test {
    ERC20Mock mockToken0;
    ERC20Mock mockToken1;
    IUtopiaPair pair;
    UtopiaFactory factory;

    function setUp() external {
        factory = new UtopiaFactory(address(this));
        mockToken0 = new ERC20Mock();
        mockToken1 = new ERC20Mock();
        pair = IUtopiaPair(factory.createPair(address(mockToken0), address(mockToken1)));
    }

    function testSwapRevertIfAmountIsZero() external {
        vm.expectRevert();
        pair.swap(0, 0, address(this));
    }
}
