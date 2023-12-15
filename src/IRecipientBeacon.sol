// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/// @author philogy <https://github.com/philogy>
interface IRecipientBeacon {
    function recipient() external view returns (address);
}
