//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {UtopiaFactory} from "../src/UtopiaFactory.sol";

contract DeployFactory is Script {
    UtopiaFactory factory;
    address wallet;

    function run() external returns (UtopiaFactory) {
        vm.startBroadcast();
        factory = new UtopiaFactory(wallet);
        vm.stopBroadcast();
        return factory;
    }
}
