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
        return deployOrUpgradeProxy(keccak256(bytes(name)), proxyOwner, implementation);
    }

    function deployOrUpgradeProxy(bytes32 salt, address proxyOwner, address implementation) public returns (address) {
        return deployOrUpgradeProxy(salt, proxyOwner, implementation, "");
    }

    function getProxyAddress(string memory name) public returns (address proxy) {
        return getProxyAddress(keccak256(bytes(name)));
    }

    function getProxyAddress(bytes32 salt) public returns (address proxy) {
        (, address sender,) = vm.readCallers();
        bytes memory creationCode = type(TransparentUpgradeableProxy).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(EMPTY_ADDRESS, sender, ""));
        proxy = vm.computeCreate2Address(salt, keccak256(bytecode));
    }

    /**
     * @dev deploys or upgrades a proxy with initial data
     * @param salt the salt for the proxy
     * @param proxyOwner the owner of the proxy
     * @param implementation the implementation of the proxy
     * @param initialiseAndUpgradeData the initialise and upgrade data for the proxy
     * @return proxy the address of the proxy
     */
    function deployOrUpgradeProxy(
        bytes32 salt,
        address proxyOwner,
        address implementation,
        bytes memory initialiseAndUpgradeData
    ) public returns (address proxy) {
        return
            deployOrUpgradeProxy(salt, proxyOwner, implementation, initialiseAndUpgradeData, initialiseAndUpgradeData);
    }

    /**
     * @dev deploys or upgrades a proxy with initial data
     * @param salt the salt for the proxy
     * @param proxyOwner the owner of the proxy
     * @param implementation the implementation of the proxy
     * @param initializationData the initialization data for the proxy
     * @param upgradeData the upgrade data for the proxy
     * @return proxy the address of the proxy
     */
    function deployOrUpgradeProxy(
        bytes32 salt,
        address proxyOwner,
        address implementation,
        bytes memory initializationData,
        bytes memory upgradeData
    ) public returns (address proxy) {
        (, address sender,) = vm.readCallers();
        proxy = getProxyAddress(salt);

        if (proxy.code.length == 0) {
            new TransparentUpgradeableProxy{salt: salt}(EMPTY_ADDRESS, sender, "");
            upgradeProxy(proxy, implementation, initializationData);
        } else {
            upgradeProxy(proxy, implementation, upgradeData);
        }

        transferProxyOwnership(proxy, proxyOwner);
    }

    /**
     * @dev upgrades a proxy to a new implementation with initialization data
     * @param proxy the address of the proxy to upgrade
     * @param implementation the new implementation address
     * @param data the initialization data for the upgrade
     */
    function upgradeProxy(address proxy, address implementation, bytes memory data) public {
        ProxyAdmin proxyAdmin = getProxyAdmin(proxy);
        if (address(uint160(uint256(vm.load(proxy, ERC1967Utils.IMPLEMENTATION_SLOT)))) != implementation) {
            proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxy), implementation, data);
        }
    }

    /**
     * @dev transfers the ownership of a proxy to a new owner
     * @param proxy the address of the proxy to transfer ownership of
     * @param proxyOwner the new owner of the proxy
     */
    function transferProxyOwnership(address proxy, address proxyOwner) public {
        ProxyAdmin proxyAdmin = getProxyAdmin(proxy);
        address currentOwner = proxyAdmin.owner();
        if (currentOwner != proxyOwner) {
            proxyAdmin.transferOwnership(proxyOwner);
        }
    }

    /**
     * @dev gets the proxy admin for a proxy
     * @param proxy the address of the proxy
     * @return proxyAdmin the proxy admin contract
     */
    function getProxyAdmin(address proxy) public view returns (ProxyAdmin proxyAdmin) {
        return ProxyAdmin(address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT)))));
    }
}
