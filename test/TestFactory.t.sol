//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {UtopiaFactory} from "../src/UtopiaFactory.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {UtopiaPair} from "../src/UtopiaPair.sol";

contract TestFactory is Test {
    ERC20Mock mockToken0;
    ERC20Mock mockToken1;
    UtopiaFactory factory;

    event PairCreated(address indexed pair, address indexed token0, address indexed token1);

    function setUp() external {
        factory = new UtopiaFactory(address(this));
        mockToken0 = new ERC20Mock();
        mockToken1 = new ERC20Mock();
    }

    function testCreatePairRevertIfSameAddress() external {
        vm.expectRevert(UtopiaFactory.Not_Same_Address.selector);
        factory.createPair(address(mockToken0), address(mockToken0));
    }

    function testFactoryCreatePairRevertIfPairExist() external {
        factory.createPair(address(mockToken0), address(mockToken1));
        vm.expectRevert(UtopiaFactory.Paire_Exists.selector);
        factory.createPair(address(mockToken0), address(mockToken1));
    }

    function testPairIsCreated() external {
        address pairCreated = factory.createPair(address(mockToken0), address(mockToken1));
        address pair = factory.getPair(address(mockToken0), address(mockToken1));
        address pair2 = factory.getPair(address(mockToken1), address(mockToken0));
        assertEq(pairCreated, pair);
        assertEq(pairCreated, pair2);
        assert(pair.code.length != 0);
    }

    function testAddressIsAccurate() external {
        bytes32 salt = keccak256(abi.encodePacked(mockToken0, mockToken1));
        bytes32 byteCode = keccak256(type(UtopiaPair).creationCode);
        address pair = computeAddress(salt, byteCode, address(factory));
        address pairCreated = factory.createPair(address(mockToken0), address(mockToken1));
        assertEq(pairCreated, pair);
    }

    function testEventIsEmittingWhenCreated() external {
        vm.expectEmit();
        factory.createPair(address(mockToken0), address(mockToken1));
    }
// this function is for computing an address before deploy it using create2.
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer)
        internal
        pure
        returns (address addr)
    {
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
