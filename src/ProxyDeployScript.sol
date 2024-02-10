// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {
    TransparentUpgradeableProxy,
    ITransparentUpgradeableProxy,
    ERC1967Utils
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Empty} from "./Empty.sol";

contract ProxyDeployScript is Script {
    address public immutable EMPTY_ADDRESS = address(new Empty{salt: 0}());

    function deployOrUpgradeProxy(string memory name, address proxyOwner, address implementation)
        public
        returns (address)
    {
        return deployOrUpgradeProxy(name, proxyOwner, implementation, "");
    }

    function deployOrUpgradeProxy(string memory name, address proxyOwner, address implementation, bytes memory data)
        public
        returns (address proxy)
    {
        bytes32 salt = keccak256(bytes(name));
        (, address sender,) = vm.readCallers();
        bytes memory creationCode = type(TransparentUpgradeableProxy).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(EMPTY_ADDRESS, sender, ""));

        proxy = vm.computeCreate2Address(salt, keccak256(bytecode));

        if (proxy.code.length == 0) {
            assembly {
                proxy := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                if iszero(extcodesize(proxy)) { revert(0, 0) }
            }
        }

        ProxyAdmin proxyAdmin = ProxyAdmin(address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT)))));
        address currentOwner = proxyAdmin.owner();

        if (address(uint160(uint256(vm.load(proxy, ERC1967Utils.IMPLEMENTATION_SLOT)))) != implementation) {
            proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxy), implementation, data);
        }

        if (currentOwner != proxyOwner) {
            if (currentOwner != sender) {
                revert("INVALID PROXY OWNER SENDER");
            }
            proxyAdmin.transferOwnership(proxyOwner);
        }
    }
}
