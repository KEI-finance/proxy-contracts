// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {Script, stdJson} from "forge-std/Script.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import "./Base.s.sol";

contract DeployScript is BaseScript {

    function run() public record {
        // deploy contracts here
        deploy("Empty.sol");
    }
}
