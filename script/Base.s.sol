// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {stdJson} from "forge-std/StdJson.sol";
import {BaseDeployScript} from "@kei.fi/testing-lib/BaseDeployScript.sol";

abstract contract BaseScript is BaseDeployScript {
    using stdJson for string;

    struct DeployConfig {
        address owner;
    }
    // TODO complete this

    DeployConfig internal config;

    function setUp() public virtual override {
        super.setUp();
        loadConfig();
    }

    function loadConfig() internal virtual {
        (string memory key, string memory json) = loadJson();
    }
}
