// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Empty} from "./Empty.sol";
import {ProxyDeployScript} from "./ProxyDeployScript.sol";

contract ProxyDeployTest is Test, ProxyDeployScript {
    constructor() {
        Empty empty = new Empty();
        vm.etch(EMPTY_ADDRESS, address(empty).code);
    }
}
