// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {BaseDeployScript} from "@kei.fi/testing-lib/BaseDeployScript.sol";

abstract contract BaseScript is BaseDeployScript {
    using stdJson for string;

    struct DeployConfig {}

    DeployConfig internal config;

    function setUp() public virtual override {
        super.setUp();
        loadConfig();
    }

    function loadConfig() internal virtual {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config.json");
        string memory json = vm.readFile(path);

        string memory key = string.concat(".", vm.envString("ENV"), ".", vm.toString(block.chainid));

        console2.log(key);

        if (!vm.keyExists(json, key)) {
            key = ".develop.11155111"; // use sepolia as a fallback
        }

        if (!vm.keyExists(json, string.concat(key, ".salt"))) {
            salt = bytes32(json.readUint(string.concat(key, ".salt")));
        }
    }
}
