// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {ProxyDeployScript, ProxyAdmin} from "../src/ProxyDeployScript.sol";

contract TestContract {
    function test() external pure returns (bool) {
        return true;
    }
}

contract ProxyDeployScriptTest is Test, ProxyDeployScript{

    address public BOB = makeAddr("BOB");

    function test_success() public {
        ProxyAdmin admin = new ProxyAdmin(address(this));
        TestContract tst = new TestContract();

        vm.startPrank(BOB);
        address proxy = deployOrUpgradeProxy(address(admin), address(tst), "");
        vm.stopPrank();

        assertTrue(TestContract(proxy).test());
    }
}
