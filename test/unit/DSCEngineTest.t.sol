// // SPDX-License-Identfier: MIT

// pragma solidity ^0.8.19;

// import {Test} from "forge-std/Test.sol";
// import {console} from "forge-std/console.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// contract DSCEngineTest is Test {
//     DeployDSC deployer;
//     DecentralizedStableCoin dsc;
//     DSCEngine dsce;
//     HelperConfig config;
//     address ethUsdPriceFeed;
//     address weth;
//     address btcUsdPriceFeed;
//     address wbtc;

//     address public USER = makeAddr("user");
//     uint256 public constant AMOUNT_COLLATERAL = 10 ether;
//     uint256 public constant USD_VALUE_PER_ETHER = 2000;
//     uint256 public constant STARTING_WETH_BALANCE = 10 ether;
//     uint256 public constant AMOUNT_TO_MINT = 2 ether;

//     function setUp() public {
//         deployer = new DeployDSC();
//         (dsc, dsce, config) = deployer.run();

//         (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = config.activeNetworkConfig();

//         ERC20Mock(weth).mint(USER, STARTING_WETH_BALANCE);
//     }

//     address[] public tokenAddresses;
//     address[] public priceFeedAddresses;

//     // function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
//     //     tokenAddresses.push(weth);
//     //     priceFeedAddresses.push(ethUsdPriceFeed);
//     //     tokenAddresses.push(wbtc);

//     //     vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceAddressesMustBeTheSameLength.selector);

//     //     new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
//     // }

//     function testGetUsdValue() public {
//         uint256 ethAmount = 15e18;
//         uint256 expectedUsd = 15e18 * 2000;
//         uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);
//         assertEq(expectedUsd, actualUsd);
//     }

//     function testRevertsIfCollateralIsZero() public {
//         vm.startPrank(USER);
//         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

//         vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
//         dsce.depositCollateral(weth, 0);
//         vm.stopPrank();
//     }

//     function testGetTokenAmountFromUsd() public {
//         uint256 usdAmount = 100 ether;
//         uint256 expectedWeth = 0.05 ether;
//         uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
//         assertEq(expectedWeth, actualWeth);
//     }

//     function testReverstsWithUnapprovedCollateral() public {
//         ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
//         vm.startPrank(USER);
//         vm.expectRevert(DSCEngine.DSCEngine__TokenNotAllowed.selector);
//         dsce.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
//     }

//     modifier depositedCollateral() {
//         vm.startPrank(USER);
//         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
//         dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
//         vm.stopPrank();
//         _;
//     }

//     function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
//         (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);

//         uint256 expectedTotalDscMinted = 0;
//         uint256 expectedDepositedAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
//         assertEq(totalDscMinted, expectedTotalDscMinted);
//         assertEq(AMOUNT_COLLATERAL, expectedDepositedAmount);
//     }

//     function testCannotMintZero() public {
//         vm.startPrank(USER);
//         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

//         dsce.depositCollateral(weth, 5e18);
//         vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
//         dsce.mintDsc(0);
//         vm.stopPrank();
//     }

//     function testDscIsMintedWhenEnoughCollateralIsDeposited() public depositedCollateral {
//         uint256 dscToMint = 2e18;
//         vm.startPrank(USER);
//         dsce.mintDsc(dscToMint);
//         uint256 usersBalanceOfDsc = dsc.balanceOf(USER);
//         assertEq(dscToMint, usersBalanceOfDsc);
//         vm.stopPrank();
//     }

//     // function testDscMintIsRevertedWhenHealthFactorIsBroken() public {
//     //     // must be 200% over collateralized (so have > 100% mroe collateral in he system than deposited)
//     //     // a scenario where the health factor would be broken would be that
//     // }

//     // function - test like the one above but when the dsc minted amount would cause the balance to be undercollateralized

//     function testAccountInformationIsCorrectFollowingMinting() public depositedCollateral {
//         uint256 dscToMint = 2e18;
//         uint256 totalDscMinted;
//         uint256 collateralValueInUsd;
//         vm.startPrank(USER);
//         dsc.approve(address(dsce), dscToMint);
//         dsce.mintDsc(dscToMint);

//         (totalDscMinted, collateralValueInUsd) = dsce.getAccountInformation(USER);
//         vm.stopPrank();
//         assertEq(totalDscMinted, dscToMint);
//         assertEq(collateralValueInUsd, AMOUNT_COLLATERAL * USD_VALUE_PER_ETHER);
//     }

//     function testHealthFactorIsWhatWouldBeExpected() public depositedCollateral {
//         uint256 dscToMint = 2e18;
//         uint256 totalDscMinted;
//         uint256 collateralValueInUsd;
//         vm.startPrank(USER);
//         dsc.approve(address(dsce), dscToMint);
//         dsce.mintDsc(dscToMint);
//         // AMOUNT_COLLATERAL * USD_VALUE_PER_ETHER = collateralvalueinusd
        
//         console.log("user health factor:", dsce.getHealthFactor(USER));
//         //* expectation:  AMOUNT_COLLATERAL * USD_VALUE_PER_ETHER * 0.5 * 1e18 / 2e18
//         //* expectation:  10e18 * 2000 * 0.5 * 1e18 / 2e18 = 5e21
//         assertEq(dsce.getHealthFactor(USER), 5e21);


//         vm.stopPrank();
//     }

//     function testDscCanBeBurnedFollowingBeingMinted() public {
//         uint256 dscToMint = 2e18;
//         vm.startPrank(USER);
//         console.log("user:", USER);
//         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

//         dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
//         dsc.approve(address(dsce), dscToMint);
//         dsce.mintDsc(dscToMint);
//         // dsce.approve(address(dsce))
//         dsce.burnDsc(dscToMint);
//         assertEq(dsc.balanceOf(USER), 0);
//     }
// // modifier depositedCollateralAndMintedDsc() {
// //     uint totalDscMinted;
// //     uint collateralValueInUsd;
// //         vm.startPrank(USER);
// //         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
// //         dsce.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
// //         (totalDscMinted, collateralValueInUsd) = dsce.getAccountInformation(USER);
// //         assertEq(totalDscMinted, AMOUNT_TO_MINT);
// //         vm.stopPrank();
// //         _;
// //     }
//     function testCanBurnDsc() public  {
//         uint totalDscMinted;
//     uint collateralValueInUsd;
//         vm.startPrank(USER);
//         ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
//         dsce.depositCollateralAndMintDsc(weth, AMOUNT_COLLATERAL, AMOUNT_TO_MINT);
//         (totalDscMinted, collateralValueInUsd) = dsce.getAccountInformation(USER);
//         assertEq(totalDscMinted, AMOUNT_TO_MINT);
        
//         dsc.approve(address(dsce), AMOUNT_TO_MINT);
//         dsce.burnDsc(AMOUNT_TO_MINT);
//         vm.stopPrank();

//         uint256 userBalance = dsc.balanceOf(USER);
//         assertEq(userBalance, 0);
//     }

//     function testDscToBeBurnedMustBeGreaterThanZero() public {}

//     function testCollateralCanBeRedeemedFollowingDscBeingBurnedFollowingDscBeingMinted() public {}

//     // function testCollateralCanBeReeemedFollowingTheReturnOfDsc() public {
//     //     // deposit collateral --> mint dsc --> call redeemCollateralForDsc
//     //     uint dscToMint = 2e18;
//     //     vm.startPrank(USER);
//     //     ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

//     //     dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
//     //     dsce.mintDsc(dscToMint);

//     //     dsce.redeemCollateralForDsc(weth, AMOUNT_COLLATERAL, dscToMint);
//     //     // assertEq(dsc.balanceOf(USER), 0);
//     //     // assertEq(ERC20Mock(weth).balanceOf(USER), STARTING_WETH_BALANCE);

//     //     vm.stopPrank();
//     // }
// }
