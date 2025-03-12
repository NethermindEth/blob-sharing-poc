// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title Minimal Batcher
/// @dev This contract becomes the EIP-7702 account-code for the proposer's EOA
contract MinimalBatcher {
    struct Call {
        address target;
        uint256 value;
        bytes data;
    }

    error CALL_FAILED(uint256 index);

    function executeBatch(Call[] calldata calls) external {
        for (uint256 i; i < calls.length; ++i) {
            (bool success,) = calls[i].target.call{value: calls[i].value}(calls[i].data);
            require(success, CALL_FAILED(i));
        }
    }
}
