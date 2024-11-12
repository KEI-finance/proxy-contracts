// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "@kei.fi/testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest, DeployScript {
    function setUp() public virtual override {
        super.setUp();
    }
}

contract DeployTest__run is DeployTest {
    struct ExpectDeployment {
        string name;
        address addr;
    }

    mapping(uint256 => ExpectDeployment[]) internal expected;

    function setUp() public virtual override {
        super.setUp();

        // forge test network
        expected[31337].push(ExpectDeployment("Empty", 0x18c5C895e010796da8903b3469138615d9Ae1c2a));
        // abitrum network
        expected[42161].push(ExpectDeployment("Empty", 0x18c5C895e010796da8903b3469138615d9Ae1c2a));
        // sepolia network
        expected[11155111].push(ExpectDeployment("Empty", 0x18c5C895e010796da8903b3469138615d9Ae1c2a));
    }

    function assert_deployments() public {
        ExpectDeployment[] memory deployments = expected[block.chainid];
        for (uint256 i; i < deployments.length; i++) {
            ExpectDeployment memory expectedDeployment = deployments[i];
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

    function test_deploy() external {
        run();
        assert_deployments();
    }
}
