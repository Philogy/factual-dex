// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IRecipientBeacon} from "./IRecipientBeacon.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

/// @author philogy <https://github.com/philogy>
contract GhostDeposit {
    using SafeTransferLib for address;

    constructor(address asset) {
        asset.safeTransferAll(IRecipientBeacon(msg.sender).recipient());
        // Optimization to ensure no code is actually deployed.
        assembly {
            stop()
        }
    }
}
