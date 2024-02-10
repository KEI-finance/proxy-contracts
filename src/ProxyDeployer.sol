// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract ProxyDeployScript {

    address public constant EMPTY_ADDRESS = 0x0;

    function deployOrUpgradeProxy(address proxyAdmin, address implementation) public {
        bytes memory creationCode = type(TransparentUpgradeableProxy).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(EMPTY_ADDRESS, proxyAdmin, ""));



        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }
}
