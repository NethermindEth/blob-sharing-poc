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

    error INVALID_ETHER_AMOUNT();
    error NOT_AUTHORIZED();
    error CALL_FAILED(uint256 index);

    event ExecutedCall(address indexed target, uint256 value, bytes data);

    function executeBatch(Call[] calldata calls) external payable {
        require(msg.sender == address(this), NOT_AUTHORIZED());

        uint256 totalValue;
        for (uint256 i; i < calls.length; ++i) {
            totalValue += calls[i].value;
            (bool success,) = calls[i].target.call{value: calls[i].value}(calls[i].data);
            require(success, CALL_FAILED(i));

            emit ExecutedCall(calls[i].target, calls[i].value, calls[i].data);
        }

        require(msg.value == totalValue, INVALID_ETHER_AMOUNT());
    }
}
