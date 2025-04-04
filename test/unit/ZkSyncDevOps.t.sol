//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //instead of the commented command-> so that we do not need to update this run manually.
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log("msg.sender", msg.sender);
        console.log("fundMe.i_owner()", fundMe.getOwner());
        console.log("this", address(this));
        // assertEq(fundMe.i_owner(), address(this));
        // this will throw an error since after vm.broadcast,
        // when we create a fundMe, the owner of fundMe is the msg.sender.!!
        // so we need to update the test case as below.
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        //uint256 expectedVersion = block.chainid == 1 ? 6 : 4; // Mainnet = 6, Sepolia = 4
        //assertEq(fundMe.getVersion(), expectedVersion);

        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //hey next line should revert
        fundMe.fund(); //empty means it will fail = 0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        // Step 2: Retrieve the first funder from the `funders` array
        address funder = fundMe.getFunder(0); // Call the getter function to get the funder at index 0 of the `funders` array
        //each time this function is called, so index will be 0.

        // Step 3: Assert that the funder at index 0 is indeed `alice`
        assertEq(funder, USER); // Check that the value retrieved from `getFunder(0)` matches `alice`'s address
    }

    modifier funded() {
        // Step 1: Simulate a user (`alice`) making a donation to the contract
        vm.prank(USER); // the next will be sent by USER // Temporarily set `msg.sender` to `alice` for the next transaction
        fundMe.fund{value: SEND_VALUE}(); // `USER` sends `SEND_VALUE` (0.1 ether, for example) to the contract via the `fund()` function
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // Step 1: Simulate USER funding the contract
        vm.prank(USER); // Temporarily set msg.sender to USER and USER funds the contract with SEND_VALUE (funded modifier)
        // actually no need to write above line, since we have already written the modifier, but ok.
        // Step 2: Expect the next transaction to fail
        vm.expectRevert(); // Expect the withdraw function call to revert (fail)

        // Step 3: Simulate USER attempting to withdraw
        fundMe.withdraw(); // USER tries to withdraw funds but is not the owner, so this should fail
    }

    function testWithdrawFromASingleFunder() public funded {
        // **ARRANGE**
        // Step 1: Record the starting balances before the withdrawal
        uint256 startingFundMeBalance = address(fundMe).balance; // Initial balance of the FundMe contract
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Initial balance of the contract owner (the withdrawer)
        // **ACT**
        // Step 2: Perform the withdrawal action
        vm.startPrank(fundMe.getOwner()); // Temporarily set msg.sender to the contract owner
        fundMe.withdraw(); // Owner withdraws all funds from the contract
        vm.stopPrank(); // End the prank; msg.sender is restored to default

        // Step 3: Record the balances after the withdrawal
        uint256 endingFundMeBalance = address(fundMe).balance; // Final balance of the FundMe contract (should be 0)
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // Final balance of the contract owner (should increase)

        //**ASSERT**
        // Step 4: Assert that the contract balance is zero after withdrawal
        assertEq(endingFundMeBalance, 0); // Verify the contract balance is now 0

        // Step 5: Assert that the owner's final balance matches the initial balances plus the withdrawn funds
        assertEq(
            startingFundMeBalance + startingOwnerBalance, // Total balance before the withdrawal
            endingOwnerBalance // Owner's balance after receiving the withdrawn funds (should increase by the withdrawn amount)
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Step 1: Set up multiple funders for the contract
        uint160 numberOfFunders = 10; // Total number of additional funders to simulate
        uint160 startingFunderIndex = 1; // Start index for funders, skipping 0 (to avoid using address(0))
        // address should be int160, not 256

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank (set msg.sender temporarily) + vm.deal (assign ETH to an address) = hoax
            hoax(address(i), SEND_VALUE); // Mock address(i) with ETH balance and simulate it as msg.sender

            fundMe.fund{value: SEND_VALUE}(); // Each mocked funder sends SEND_VALUE ETH to the contract
            //fund the fundMe
            /* log funders and funds
            console.log("Funder:", address(i));
            console.log("Amount of fund:", SEND_VALUE);
            console.log("fundMe Balance:", address(fundMe).balance); */
        }

        // Step 2: Record the initial balances before the withdrawal
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Initial ETH balance of the contract owner
        uint256 startingFundMeBalance = address(fundMe).balance; // Total ETH balance in the contract

        //Act
        // Step 3: Perform the withdrawal action
        uint256 gasStart = gasleft(); // Record the gas remaining before the withdrawal
        vm.txGasPrice(GAS_PRICE); // Set the gas price for the next transaction
        vm.startPrank(fundMe.getOwner()); // Temporarily set msg.sender to the contract owner
        fundMe.withdraw(); // The owner withdraws all funds from the contract
        vm.stopPrank(); // End the prank; msg.sender returns to its default state
        uint256 gasEnd = gasleft(); // Record the gas remaining after the withdrawal
        //console.log("Gas used for withdrawal:", gasStart - gasEnd); // Calculate the gas used for the withdrawal
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // Calculate the gas used for the withdrawal
        console.log("Gas used for withdrawal:", gasUsed); // Print the gas used for the withdrawal
        //assert
        // Step 4: Assert the contract's balance is zero after withdrawal
        assert(address(fundMe).balance == 0); // Verify the contract balance is now 0, since all funds were withdrawn
        // Step 5: Assert the owner's balance increased by the amount withdrawn

        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        ); // Owner's balance should increase by the total contract balance
        // Step 6: Verify that the total funds contributed match the owner's balance gain
        /* assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fundMe.getOwner().balance - startingOwnerBalance
        ); */

        // Explanation:
        // - Each of the 10 additional funders contributed SEND_VALUE.
        // - The `+1` accounts for `USER` (alice) (from the **funded** modifier) who also contributed SEND_VALUE.
        // - The owner's balance gain should match the total contributions by all funders.
    }
}
