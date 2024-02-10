// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, stdJson} from "forge-std/Script.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import "./Base.s.sol";

contract DeployScript is BaseScript {
    using stdJson for string;

    function run() public {
        vm.startBroadcast(deployer);

        new ProxyAdmin{salt: config.salt}(config.owner);

        vm.stopBroadcast();
    }
}
