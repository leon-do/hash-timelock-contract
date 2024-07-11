// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, stdError} from "forge-std/Test.sol";
import {HTLC} from "../src/HTLC.sol";

contract HTLCTest is Test {
    HTLC public htlc;
    address fromAddress = vm.addr(1);
    address toAddress = vm.addr(2);
    bytes32 preimage = 0xa492d599fb01a1801f3b810b0f8fd8e3efe9725ecbbe43e7341333c86407fab7;
    bytes32 hash = 0x829737b3a9e8f4f58167ff3105d211dedfec64cddfc091444283592b9dfdac12;

    function setUp() public {
        htlc = new HTLC();
        vm.prank(fromAddress);
        vm.deal(fromAddress, 10 ether);
    }

    function test_InitialState() public view {
        (address from, uint256 value, address to, uint256 time, bool done) = htlc.vault(hash);
        assertEq(from, 0x0000000000000000000000000000000000000000);
        assertEq(value, 0);
        assertEq(to, 0x0000000000000000000000000000000000000000);
        assertEq(time, 0);
        assertEq(done, false);
    }

    function test_Deposit() public {
        // before deposit
        uint256 initialBalance = address(fromAddress).balance;
        // deposit
        uint256 depositValue = 3 ether;
        htlc.deposit{value: depositValue}(toAddress, hash);
        // after deposit
        (address from, uint256 value, address to, uint256 time, bool done) = htlc.vault(hash);
        assertEq(from, fromAddress);
        assertEq(value, depositValue);
        assertEq(to, toAddress);
        assertEq(time, 301);
        assertEq(done, false);
        assertEq(address(fromAddress).balance, initialBalance - depositValue);
        assertEq(address(htlc).balance, depositValue);
    }

    function test_RevertIfDepositEmpty() public {
        // 0 deposit should revert
        vm.expectRevert(bytes("Value empty"));
        htlc.deposit{value: 0}(toAddress, hash);
    }

    function test_RevertIfDepositTwice() public {
        // first deposit
        htlc.deposit{value: 1}(toAddress, hash);
        // second deposit should revert
        vm.expectRevert(bytes("Vault exists"));
        htlc.deposit{value: 1}(toAddress, hash);
    }

    function test_Withdraw() public {
        // initial balances
        uint256 initialBalance = address(fromAddress).balance;
        assertEq(address(toAddress).balance, 0);
        // deposit
        uint256 depositValue = 3 ether;
        htlc.deposit{value: depositValue}(toAddress, hash);
        // withdraw
        htlc.withdraw(preimage);
        // final balance
        assertEq(address(fromAddress).balance, initialBalance - depositValue);
        assertEq(address(toAddress).balance, depositValue);
    }

    function test_RevertIfWithdrawBad() public {
        // deposit
        htlc.deposit{value: 1}(toAddress, hash);
        // withdraw should revert
        vm.expectRevert(bytes("Vault empty"));
        bytes32 incorrectPreimage = 0x829737b3a9e8f4f58167ff3105d211dedfec64cddfc091444283592b9dfdac13;
        htlc.withdraw(incorrectPreimage);
    }

    function test_RevertIfWithdrawTwice() public {
        // deposit
        htlc.deposit{value: 1}(toAddress, hash);
        // withdraw
        htlc.withdraw(preimage);
        // withdraw
        vm.expectRevert(bytes("Vault closed"));
        htlc.withdraw(preimage);
    }

    function test_Refund() public {
        uint256 initialBalance = address(fromAddress).balance;
        // deposit
        uint256 depositValue = 3 ether;
        htlc.deposit{value: depositValue}(toAddress, hash);
        // balance after deposit
        assertEq(address(fromAddress).balance, initialBalance - depositValue);
        // wait at least 5 minutes
        vm.warp(10 minutes);
        // refund
        htlc.refund(hash);
        // after refund
        (address from, uint256 value, address to, uint256 time, bool done) = htlc.vault(hash);
        // balance after refund
        assertEq(address(fromAddress).balance, initialBalance);
    }

    function test_RevertIfRefundUnexpired() public {
        // deposit
        htlc.deposit{value: 1}(toAddress, hash);
        // refund immediately
        vm.expectRevert(bytes("Vault unexpired"));
        htlc.refund(hash);
    }

    function test_RevertIfRefundTwice() public {
        // deposit
        htlc.deposit{value: 1}(toAddress, hash);
        // wait at least 5 minutes
        vm.warp(10 minutes);
        htlc.refund(hash);
        // refund again
        vm.expectRevert(bytes("Vault closed"));
        htlc.refund(hash);
    }

    function test_RevertIfRefundRandom() public {
        // random hash
        bytes32 hash = 0x829737b3a9e8f4f58167ff3105d211dedfec64cddfc091444283592b9dfdac13;
        htlc.refund(hash);
        vm.expectRevert(bytes("Vault closed"));
        htlc.refund(hash);
    }
}
