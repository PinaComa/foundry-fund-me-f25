/** 
 * Currently, running tests locally or on different chains is inflexible. 
 * Your contracts depend on Sepolia’s hardcoded priceFeed address.
 *  This approach:
    -Relies on forked chains: Tests fail if you don’t fork Sepolia.
    -Lacks flexibility: It’s hard to switch to other chains without rewriting code or hardcoding new addresses.
    -Complicates testing: Running all tests locally is inefficient or error-prone.
    The Goal:
    -Run all tests locally on Anvil (a Foundry-powered blockchain emulator) 
        without requiring a forked chain like Sepolia.
    -Use a mock contract on Anvil to simulate the behavior 
        of the priceFeed contract instead of interacting with live blockchains.
    -Make deployment and testing modular by dynamically configuring addresses 
        (e.g., priceFeed) based on the blockchain being used.
 * 
 * 
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local Anvil, we deploy the mocks
    // Else, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // Mainnet ETH/USD
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } /* In Solidity, when a variable
        of type address is declared but not assigned, 
        its default value is address(0) 
        (an address of all zeros).
        We use this fact to determine if a mockPriceFeed 
        has already been deployed.*/

        vm.startBroadcast();
        // Deploy a mock price feed contract
        // This is a placeholder for the real price feed contract
        // that we will interact with on the live network
        // This mock will be used on Anvil
        // AggregatorV3Interface mockPriceFeed = new MockPriceFeed();
        // return NetworkConfig({
        //     priceFeed: address(mockPriceFeed)
        // });
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
