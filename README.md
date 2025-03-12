# Blob Sharing POC

A proof-of-concept implementation demonstrating cross-rollup blob sharing using EIP-7702. This implementation allows multiple rollup inboxes to efficiently share the same blob data, reducing data availability costs.

## Overview

This POC implements a system where:

- Multiple minimal inboxes can receive blob data
- A batcher contract coordinates blob proposals across inboxes
- EIP-7702 is used to make the batcher the account code for the proposer

### Key Components

1. **MinimalInbox**: Contract that receives and processes blob segments
2. **MinimalBatcher**: EIP-7702 account code that enables batched proposal calls
3. **Deployment Script**: Deploys the batcher and inbox contracts
4. **Proposal Script**: Builds calldata for batched proposal execution

## Prerequisites

- Foundry installed
- Local Ethereum node with Prague hardfork enabled (e.g., Anvil)
- Basic understanding of EIP-4844 (blob transactions) and EIP-7702

## Installation & Setup

1. **Deploy the batcher and minimal inboxes**:

```bash
export PROPOSER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
forge script ./script/Deploy.s.sol --rpc-url 127.0.0.1:8545 --broadcast
```

2. **Set up the EIP-7702 authorization**:

The minimal batcher is set as the account code for the proposer, allowing it to send the same blob to multiple inboxes.

```bash
cast send $(cast az) --auth 0x5FbDB2315678afecb367f032d93F642f64180aa3 --private-key ${PRIVATE_KEY}
```

3. **Set environment variables for deployed contracts**:

These addresses are generated during the deployment sequence using the first private key in Anvil.

```bash
export MINIMAL_BATCHER=0x5FbDB2315678afecb367f032d93F642f64180aa3
export INBOX_A=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
export INBOX_B=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

## Usage

1. **Build proposal calldata**:

A blob segment is defined by the `BlobSegment` struct, which includes `firstBlobIndex`, `numBlobs`, `offset`, and `length`. The tuple in the command represents these values.

```bash
# Format: forge script ./script/ProposalCalls.s.sol --sig "build((uint64,uint8,uint64,uint64),(uint64,uint8,uint64,uint64))" "firstSegment" "secondSegment"
# Example for two blob segments:
forge script ./script/ProposalCalls.s.sol --sig "build((uint64,uint8,uint64,uint64),(uint64,uint8,uint64,uint64))" "(0,1,0,50)" "(0,1,50,50)"
```

The output is the `[CALLDATA]` used in the next command.

2. **Execute the proposal**:

The transaction is sent to the proposer's own address, with EIP-7702 enabling the batcher to act on behalf of the proposer. The contents of the `blobdata` file represent the blob content.

```bash
cast send ${PROPOSER} [CALLDATA] --private-key ${PRIVATE_KEY} --blob --path ./blobdata
```

## Verifying Logs

- The `ProposedBlock` event provides enough data for the node to reconstruct the transaction list from the blob data.
- The structure of the `BlockProposed` event includes:
  - `id`: The block ID.
  - `proposer`: The address of the block proposer.
  - `txsHash`: The hash of the transactions.
  - `blobSegmentHash`: The hash of the blob segment.

An important aspect is that due to EIP-7702, the original sender, i.e., our proposer, is the eventual recorded proposer in both the inboxes that share the same blob. This is evident from the second topic in the logs below.

**Event log for inbox A for first block proposal**:

```json
{
  "topics": [
    "0x6370ac6948b0eb59504796a4379e22ed17563db0923328fa62a00619a4bbec04",
    "0x0000000000000000000000000000000000000000000000000000000000000001",
    "0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"
  ],
  "data": "0xb10c5216548210b998e7dfe8c3d9481a416ef1e90aacc986916e463215214264981e310ae5b7fd817630f5b46af1af0517df36b2a80be8d315ebef4b9054938a"
}
```

**Event log for inbox B for first block proposal**:

```json
{
  "topics": [
    "0x6370ac6948b0eb59504796a4379e22ed17563db0923328fa62a00619a4bbec04",
    "0x0000000000000000000000000000000000000000000000000000000000000001",
    "0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"
  ],
  "data": "0xb10c5216548210b998e7dfe8c3d9481a416ef1e90aacc986916e463215214264aef0e6d5ab8c404726a2ed5410ce1b6e1b98a334f88f58ccbdd83f1aa9560b20"
}
```

## References

- [EIP-4844](https://eips.ethereum.org/EIPS/eip-4844): Shard Blob Transactions
- [EIP-7702](https://eips.ethereum.org/EIPS/eip-7702): Account Abstraction via Alternative Mempools
