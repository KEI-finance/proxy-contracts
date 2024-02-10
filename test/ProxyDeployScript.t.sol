// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {ProxyDeployScript, ProxyAdmin, Empty} from "../src/ProxyDeployScript.sol";

contract TestContract {
    function test() external pure returns (bool) {
        return true;
    }
}

contract ProxyDeployScriptTest is Test, ProxyDeployScript {
    address public BOB = makeAddr("BOB");

    constructor() {
        Empty empty = new Empty();
        vm.etch(EMPTY_ADDRESS, address(empty).code);
    }

    function test_success() public {
        TestContract tst = new TestContract();

        vm.startBroadcast(BOB);
        address proxy = deployOrUpgradeProxy("Test", BOB, address(tst));
        address proxy2 = deployOrUpgradeProxy("Test", BOB, address(tst));
        vm.stopBroadcast();

        assertEq(proxy, proxy2);

        assertTrue(TestContract(proxy).test());
    }
}
