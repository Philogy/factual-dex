// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IRecipientBeacon} from "./IRecipientBeacon.sol";
import {EIP712} from "solady/src/utils/EIP712.sol";
import {GhostDeposit} from "./GhostDeposit.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

/// @author philogy <https://github.com/philogy>
contract FactualDEX is IRecipientBeacon, EIP712 {
    using SafeTransferLib for address;
    using SignatureCheckerLib for address;

    error InvalidSignature();

    // Non-zero base-state is small optimization that can minimize gas refund losses.
    address public recipient = address(1);

    bytes32 internal constant ORDER_TYPEHASH = keccak256("Order(address asset,uint256 amount,bytes32 salt)");

    function fillOrder(address owner, address asset, bytes32 salt, bytes calldata signature) external payable {
        if (!owner.isValidSignatureNowCalldata(getOrderMessageHash(asset, msg.value, salt), signature)) {
            revert InvalidSignature();
        }
        recipient = msg.sender;
        new GhostDeposit{salt: getSalt(owner, salt)}(asset);
        recipient = address(1);
        owner.safeTransferETH(msg.value);
    }

    function getOrderMessageHash(address asset, uint256 amount, bytes32 salt) public view returns (bytes32) {
        return _hashTypedData(keccak256(abi.encode(ORDER_TYPEHASH, asset, amount, salt)));
    }

    function getDepositAddress(address owner, address asset, bytes32 salt) public view returns (address) {
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(hex"ff"),
                            address(this),
                            getSalt(owner, salt),
                            keccak256(abi.encodePacked(type(GhostDeposit).creationCode, abi.encode(asset)))
                        )
                    )
                )
            )
        );
    }

    function getSalt(address owner, bytes32 innerSalt) internal pure returns (bytes32) {
        return keccak256(abi.encode(owner, innerSalt));
    }

    function _domainNameAndVersion() internal pure override returns (string memory name, string memory version) {
        name = "FactualDEX";
        version = "1";
    }
}
