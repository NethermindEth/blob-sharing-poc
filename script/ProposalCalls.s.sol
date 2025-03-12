// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MinimalInbox} from "src/MinimalInbox.sol";
import {MinimalBatcher} from "src/MinimalBatcher.sol";

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

contract ProposalCalls is Script {
    address minimalBatcher = vm.envAddress("MINIMAL_BATCHER");
    address inboxA = vm.envAddress("INBOX_A");
    address inboxB = vm.envAddress("INBOX_B");

    function build(
        MinimalInbox.BlobSegment calldata _blobSegmentA,
        MinimalInbox.BlobSegment calldata _blobSegmentB
    ) external view {
        MinimalBatcher.Call[] memory calls = new MinimalBatcher.Call[](2);

        // Encode the call to proposeBlock for inboxA
        calls[0] = MinimalBatcher.Call({
            target: inboxA,
            value: 0,
            data: abi.encodeWithSelector(MinimalInbox.proposeBlock.selector, _blobSegmentA)
        });

        // Encode the call to proposeBlock for inboxB
        calls[1] = MinimalBatcher.Call({
            target: inboxB,
            value: 0,
            data: abi.encodeWithSelector(MinimalInbox.proposeBlock.selector, _blobSegmentB)
        });

        console2.logBytes(abi.encode(calls));
    }
}
