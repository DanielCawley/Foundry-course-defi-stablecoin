// SPDX-License-Identfier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        //! anvil account 1 - change this when working on not anvil (sepolia) - maybe add this to network config
        DecentralizedStableCoin dsc = new DecentralizedStableCoin(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
        // vm.prank(owner);
        // ! this line is dubious, as the structure of the only ownabe modifier has changed, if this is causing you heartache, go into the openzeppelin onlyowner code and modify it to be like the legacy version
        dsc.transferOwnership(address(DSCEngine(engine)));
        vm.stopBroadcast();
        return (dsc, engine, config);
    }
}
