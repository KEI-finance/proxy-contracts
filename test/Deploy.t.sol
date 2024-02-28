// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "@kei.fi/testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest, DeployScript {
    struct ExpectDeployment {
        string name;
        address addr;
    }

    ExpectDeployment[] internal expected;

    function setUp() public virtual override {
        super.setUp();
        expected.push(ExpectDeployment("AccountSetup.sol", 0x0000000000000000000000000000000000000000));
    }

    function test_deploy() external {
        vm.chainId(11155111);

        run();

        for (uint256 i; i < expected.length; i++) {
            ExpectDeployment memory expectedDeployment = expected[i];
            address deployment = deployment[expectedDeployment.name];
            assertEq(
                deployment,
                expectedDeployment.addr,
                string.concat(
                    expectedDeployment.name,
                    " address has changed. Current Address: ",
                    vm.toString(deployment),
                    ". Expected address: ",
                    vm.toString(expectedDeployment.addr)
                )
            );
        }
    }
}
