// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MinimalInbox} from "src/MinimalInbox.sol";
import {MinimalBatcher} from "src/MinimalBatcher.sol";

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

contract Deploy is Script {
    modifier broadcast() {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        _;
        vm.stopBroadcast();
    }

    function run() external broadcast {
        address minimalBatcher = address(new MinimalBatcher());
        address inboxA = address(new MinimalInbox());
        address inboxB = address(new MinimalInbox());

        console2.log("MinimalBatcher deployed at:", minimalBatcher);
        console2.log("InboxA deployed at:", inboxA);
        console2.log("InboxB deployed at:", inboxB);
    }
}
