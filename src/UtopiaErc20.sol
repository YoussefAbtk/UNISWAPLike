//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UtopiaCoin is ERC20 {
    constructor() ERC20("Utopia Coin", "UC") {}
}