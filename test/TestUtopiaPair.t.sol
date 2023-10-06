//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {UtopiaFactory} from "../src/UtopiaFactory.sol";
import {UtopiaPair} from "../src/UtopiaPair.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {IUtopiaPair} from "../src/interface/IUtopiaPair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestUtopiaPair is Test {
    ERC20Mock mockToken0;
    ERC20Mock mockToken1;
    IUtopiaPair pair;
    UtopiaFactory factory;
    IERC20 pairToken;
    address pairAddress;
    address USER = makeAddr("user");
    address OWNER = makeAddr("owner");

    function setUp() external {
        factory = new UtopiaFactory(address(this));
        mockToken0 = new ERC20Mock();
        mockToken1 = new ERC20Mock();
        pairAddress = factory.createPair(address(mockToken0), address(mockToken1));
        factory.setFeeTo(OWNER);
        pair = IUtopiaPair(pairAddress);
        pairToken = IERC20(pairAddress);
        vm.deal(USER, 100000 ether);
        mockToken0.mint(USER, 1000 ether);
        mockToken1.mint(USER, 1000 ether);
    }

    function testSwapRevertIfAmountIsZero() external {
        vm.expectRevert(UtopiaPair.NeedMoreThanZero.selector);
        pair.swap(0, 0, address(this));
    }

    function testSwapRevertIfNotEnoughtLiquidity() external {
        vm.expectRevert(UtopiaPair.NotEnoughtLiquidity.selector);
        pair.swap(50, 80, address(this));
    }

    modifier userMint() {
        vm.startPrank(USER);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        vm.stopPrank();
        _;
    }

    function testMintChangeBalanceUser() external {
        vm.startPrank(USER);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        vm.stopPrank();
        uint256 liquidity = pairToken.totalSupply();
        uint256 amount = 10 ether;
        uint256 totalSupplyExpected = _sqrt((amount) * (amount)) - (10 ** 3);
        uint256 userBalance = pairToken.balanceOf(USER);
        assertEq(liquidity, totalSupplyExpected);
        assertEq(liquidity, userBalance);
    }

    function testMintUpdateReserves() external {
        vm.startPrank(USER);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        vm.stopPrank();
        (uint256 _reserve0, uint256 _reserve1) = pair.getReserve();
        assertEq(_reserve0, 10 ether);
        assertEq(_reserve1, 10 ether);
    }

    function testMintUpdateK() external {
        vm.startPrank(USER);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        vm.stopPrank();

        uint256 k = pair.getK();

        uint256 kExpected = 10 ether * 10 ether;
        assertEq(k, kExpected);
    }

    function testMintUpdatePriceCummulative() external {
        vm.warp(1000);
        vm.startPrank(USER);

        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);

        pair.mint(USER);
        vm.warp(2000);
        IERC20(mockToken0).transfer(address(pair), 10 ether);
        IERC20(mockToken1).transfer(address(pair), 10 ether);
        pair.mint(USER);
        vm.stopPrank();
        (uint256 pc0, uint256 pc1) = pair.getPriceCumulative();
        console.log(pc0, pc1);
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
