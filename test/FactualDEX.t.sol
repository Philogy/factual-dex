// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {FactualDEX} from "../src/FactualDEX.sol";
import {MockERC20} from "./MockERC20.sol";
import {NotEOA} from "./NotEOA.sol";

/// @author philogy <https://github.com/philogy>
contract FactualDEXTest is Test {
    FactualDEX dex = new FactualDEX();

    function setUp() public {}

    function test_tokenBlocksContract() public {
        MockERC20 token = new MockERC20({blocking: true});
        address start = makeAddr("start");
        deal(address(token), start, 100e18);

        vm.prank(start);
        address eoa = makeAddr("eoa");
        token.transfer(eoa, 1e18);
        assertEq(token.balanceOf(eoa), 1e18);

        address notEOA = address(new NotEOA());
        assertTrue(notEOA.code.length > 0);
        vm.prank(start);
        vm.expectRevert(MockERC20.IsContract.selector);
        token.transfer(notEOA, 1);
    }

    function test_canTrade() public {
        MockERC20 token = new MockERC20({blocking: true});
        Account memory owner = makeAccount("owner");
        deal(address(token), owner.addr, 100e18);

        bytes32 salt = keccak256("random_salt_1");
        address deposit = dex.getDepositAddress(owner.addr, address(token), salt);
        vm.prank(owner.addr);
        uint256 amount = 10e18;
        token.transfer(deposit, amount);

        uint256 eth = 0.238 ether;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner.key, dex.getOrderMessageHash(address(token), eth, salt));
        bytes memory compactSig = abi.encode(r, ((uint256(v == 27 ? 0 : 1) << 255) | uint256(s)));

        address recipient = makeAddr("recipient");
        hoax(recipient, eth);
        dex.fillOrder{value: eth}(owner.addr, address(token), salt, compactSig);

        assertEq(token.balanceOf(deposit), 0);
        assertEq(token.balanceOf(recipient), amount);
        assertEq(owner.addr.balance, eth);
    }
}
