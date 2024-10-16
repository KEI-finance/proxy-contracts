// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest {
    struct ExpectDeployment {
        string name;
        address addr;
    }

    ExpectDeployment[] internal expected;

    function setUp() external {
        expected.push(ExpectDeployment("Empty.sol", 0x18c5C895e010796da8903b3469138615d9Ae1c2a));
    }

    function test_deploy() external {
        vm.chainId(5);

        DeployScript script = new DeployScript();

        script.setUp();
        script.run();

        for (uint256 i; i < expected.length; i++) {
            ExpectDeployment memory expectedDeployment = expected[i];
            address deployment = script.deployment(expectedDeployment.name);
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
