// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {console} from "forge-std/Test.sol";
<<<<<<< HEAD
import {BaseTest} from "testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest {
=======
import {BaseTest} from "@kei.fi/testing-lib/BaseTest.sol";

import {DeployScript} from "script/Deploy.s.sol";

contract DeployTest is BaseTest, DeployScript {
    function setUp() public virtual override {
        super.setUp();
    }
}

contract DeployTest__run is DeployTest {
>>>>>>> template/master
    struct ExpectDeployment {
        string name;
        address addr;
    }

<<<<<<< HEAD
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
=======
    mapping(uint256 => ExpectDeployment[]) internal expected;

    function setUp() public virtual override {
        super.setUp();

        // forge test network
        expected[31337].push(ExpectDeployment("Counter", 0xBe7AC52D4e460b465cdd8ff939275Df60Ee17483));
        // abitrum network
        expected[42161].push(ExpectDeployment("Counter", 0x0000000000000000000000000000000000000000));
        // sepolia network
        expected[11155111].push(ExpectDeployment("Counter", 0x0000000000000000000000000000000000000000));
    }

    function assert_deployments() public {
        ExpectDeployment[] memory deployments = expected[block.chainid];
        for (uint256 i; i < deployments.length; i++) {
            ExpectDeployment memory expectedDeployment = deployments[i];
            address deployment = deployment[expectedDeployment.name];
>>>>>>> template/master
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
<<<<<<< HEAD
=======

    function test_deploy() external {
        run();
        assert_deployments();
    }
>>>>>>> template/master
}
