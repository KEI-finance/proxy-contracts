// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {ProxyDeployScript, ProxyAdmin, Empty} from "../src/ProxyDeployScript.sol";
import {ProxyDeployTest} from "../src/ProxyDeployTest.sol";

contract TestContract {
    function test() external pure returns (bool) {
        return true;
    }
}

contract ProxyDeployScriptTest is Test, ProxyDeployScript, ProxyDeployTest {
    address public BOB = makeAddr("BOB");

    function test_success() public {
        TestContract tst = new TestContract();

        vm.startBroadcast(BOB);
        address proxy = deployOrUpgradeProxy(string("Test"), BOB, address(tst));
        address proxy2 = deployOrUpgradeProxy(string("Test"), BOB, address(tst));
        vm.stopBroadcast();

        assertEq(proxy, proxy2);

        assertTrue(TestContract(proxy).test());
    }
}
