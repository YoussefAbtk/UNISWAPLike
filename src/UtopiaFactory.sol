//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {UtopiaPair} from "./UtopiaPair.sol";
import {IUtopiaFactory} from "./interface/IUtopiaFactory.sol";

contract UtopiaFactory is IUtopiaFactory {
    address public feeTo;
    address public feeToSetter;
    mapping(address => mapping(address => address)) pairToToken;
    address[] public allPairs;

    error Paire_Exists();
    error Not_Same_Address();
    error Forbidden();

    event PairCreated(address indexed pair, address indexed token0, address indexed token1);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
    // It's with this function that the factory create a pair contract.

    function createPair(address tokenA, address tokenB) external returns (address) {
        if (tokenA == tokenB) {
            revert Not_Same_Address();
        }
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (pairToToken[token0][token1] != address(0)) {
            revert Paire_Exists();
        }
        bytes memory byteCode =
            abi.encodePacked(type(UtopiaPair).creationCode, abi.encode(address(this), token0, token1));
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        address pair = Create2.deploy(0, salt, byteCode);

        pairToToken[token0][token1] = pair;
        pairToToken[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(pair, token0, token1);
        return pair;
    }

    function getPair(address _tokenA, address _tokenB) external view returns (address _pair) {
        return pairToToken[_tokenA][_tokenB];
    }

    function setFeeTo(address _feeTo) external {
        if (msg.sender != feeToSetter) {
            revert Forbidden();
        }
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        if (msg.sender != feeToSetter) {
            revert Forbidden();
        }
        feeToSetter = _feeToSetter;
    }

    function getFeeTo() external view returns (address _feeTo) {
        return _feeTo = feeTo;
    }
}
