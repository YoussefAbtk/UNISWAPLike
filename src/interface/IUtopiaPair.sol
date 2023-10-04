//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IUtopiaPair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to)
        external
        returns (uint256 amount0In, uint256 amount1In);
    function getReserve() external view returns (uint112 _reserve0, uint112 _reserve1);
    function mint(address to) external  returns (uint256 liquidity); 
    function burn(address to) external  returns (uint256 amount0, uint256 amount1); 

}
