// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MinimalInbox {
    struct BlobSegment {
        // Index of the first blob
        uint64 firstBlobIndex;
        // Number of blobs that this segment spans.
        uint8 numBlobs;
        // Offset within the blob where this segment starts
        uint64 offset;
        // Length of the segment in bytes
        uint64 length;
    }

    struct Block {
        // Block height
        uint256 id;
        // Single hash representing multiple blob hashes
        bytes32 txsHash;
        // Segment of the blob containing the transactions for the block
        BlobSegment blobSegment;
    }

    event BlockProposed(uint256 indexed id, bytes32 txsHash, bytes32 blobSegmentHash);

    uint256 internal numBlocks;

    mapping(uint256 blockId => Block block) internal blocks;

    function proposeBlock(BlobSegment calldata _blobSegment) external {
        // Build a single hash for the entire transaction list
        bytes32[] memory blobHashes = new bytes32[](_blobSegment.numBlobs);
        uint256 blobIndex = _blobSegment.firstBlobIndex;
        for (uint256 i; i < _blobSegment.numBlobs; ++i) {
            blobHashes[i] = blobhash(blobIndex);
        }
        bytes32 _txsHash = keccak256(abi.encode(blobHashes));

        // Add block to storage
        uint256 _numBlocks = ++numBlocks;
        blocks[numBlocks] = Block({id: _numBlocks, txsHash: _txsHash, blobSegment: _blobSegment});

        emit BlockProposed(_numBlocks, _txsHash, keccak256(abi.encode(_blobSegment)));
    }
}
