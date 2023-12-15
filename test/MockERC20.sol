// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "solady/src/tokens/ERC20.sol";

/// @author philogy <https://github.com/philogy>
contract MockERC20 is ERC20 {
    error IsContract();

    bool internal immutable BLOCKING;

    constructor(bool blocking) {
        BLOCKING = blocking;
    }

    function name() public pure override returns (string memory) {
        return "MockERC20";
    }

    function symbol() public pure override returns (string memory) {
        return "M";
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
        if (BLOCKING && (from.code.length != 0 || to.code.length != 0)) revert IsContract();
    }
}
