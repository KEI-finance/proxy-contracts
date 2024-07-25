// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import {Script} from "forge-std/Script.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {
    TransparentUpgradeableProxy,
    ITransparentUpgradeableProxy,
    ERC1967Utils
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Empty} from "./Empty.sol";

/**
 * @title ProxyDeployScript
 * @dev Contract for deploying or upgrading Proxy script using OpenZeppelin libraries
 */
contract ProxyDeployScript is Script {
    address public immutable EMPTY_ADDRESS = 0x18c5C895e010796da8903b3469138615d9Ae1c2a;

    /**
     * @dev deploys or upgrades a proxy
     * @param name the name of the proxy
     * @param proxyOwner the owner of the proxy
     * @param implementation the implementation of the proxy
     * @return the address of the proxy
     */
    function deployOrUpgradeProxy(string memory name, address proxyOwner, address implementation)
        public
        returns (address)
    {
        return deployOrUpgradeProxy(name, proxyOwner, implementation, "");
    }

    function getProxyAddress(string memory name) public returns (address proxy) {
        bytes32 salt = keccak256(bytes(name));
        (, address sender,) = vm.readCallers();
        bytes memory creationCode = type(TransparentUpgradeableProxy).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(EMPTY_ADDRESS, sender, ""));
        proxy = vm.computeCreate2Address(salt, keccak256(bytecode));
    }

    /**
     * @dev deploys or upgrades a proxy with initial data
     * @param name the name of the proxy
     * @param proxyOwner the owner of the proxy
     * @param implementation the implementation of the proxy
     * @param data the initialization data for the proxy
     * @return proxy the address of the proxy
     */
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
            new TransparentUpgradeableProxy{salt: salt}(EMPTY_ADDRESS, sender, "");
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
