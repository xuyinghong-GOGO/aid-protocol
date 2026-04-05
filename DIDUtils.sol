// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DIDUtils
 * @notice Library for DID (Decentralized Identifier) operations
 * @dev Provides utilities for DID generation, validation, and parsing
 */
library DIDUtils {
    /**
     * @notice DID method identifier for AID Protocol
     */
    string public constant DID_METHOD = "aid";

    /**
     * @notice Error messages
     */
    error InvalidDIDFormat();
    error InvalidChainId();
    error InvalidUniqueHash();
    error EmptyDID();

    /**
     * @notice Generates a DID from chain ID and unique hash
     * @dev Format: did:aid:<chain-id>:<unique-hash>
     * @param chainId The blockchain identifier (e.g., "ethereum", "polygon", "base")
     * @param uniqueHash The unique hash (typically keccak256 of public key)
     * @return did The generated DID string
     */
    function generateDID(
        string memory chainId,
        bytes32 uniqueHash
    ) public pure returns (string memory did) {
        return string.concat(
            "did:",
            DID_METHOD,
            ":",
            chainId,
            ":",
            bytes32ToString(uniqueHash)
        );
    }

    /**
     * @notice Validates a DID format
     * @dev Checks if the DID follows the format: did:aid:<chain-id>:<unique-hash>
     * @param did The DID to validate
     * @return valid Whether the DID format is valid
     */
    function isValidDID(string memory did) public pure returns (bool valid) {
        bytes memory didBytes = bytes(did);

        // Check minimum length: "did:aid:a:b" = 12 characters
        if (didBytes.length < 12) {
            return false;
        }

        // Check prefix "did:aid:"
        bytes memory prefix = bytes("did:aid:");
        for (uint256 i = 0; i < prefix.length; i++) {
            if (didBytes[i] != prefix[i]) {
                return false;
            }
        }

        // Find chain ID part
        uint256 chainIdStart = 8; // After "did:aid:"
        uint256 chainIdEnd = chainIdStart;
        while (chainIdEnd < didBytes.length && didBytes[chainIdEnd] != 0x3A) { // 0x3A is ':'
            chainIdEnd++;
        }

        // Chain ID must not be empty
        if (chainIdEnd == chainIdStart) {
            return false;
        }

        // Unique hash must not be empty
        if (chainIdEnd >= didBytes.length - 1) {
            return false;
        }

        return true;
    }

    /**
     * @notice Extracts chain ID from a DID
     * @dev Parses the DID and returns the chain ID component
     * @param did The DID to parse
     * @return chainId The extracted chain ID
     */
    function extractChainId(string memory did) public pure returns (string memory chainId) {
        if (!isValidDID(did)) {
            revert InvalidDIDFormat();
        }

        bytes memory didBytes = bytes(did);

        // Chain ID starts after "did:aid:" (index 8)
        uint256 start = 8;
        uint256 end = start;

        // Find the second colon
        while (end < didBytes.length && didBytes[end] != 0x3A) {
            end++;
        }

        // Extract chain ID substring
        bytes memory chainIdBytes = new bytes(end - start);
        for (uint256 i = 0; i < end - start; i++) {
            chainIdBytes[i] = didBytes[start + i];
        }

        return string(chainIdBytes);
    }

    /**
     * @notice Extracts unique hash from a DID
     * @dev Parses the DID and returns the unique hash component
     * @param did The DID to parse
     * @return uniqueHash The extracted unique hash
     */
    function extractUniqueHash(string memory did) public pure returns (bytes32 uniqueHash) {
        if (!isValidDID(did)) {
            revert InvalidDIDFormat();
        }

        bytes memory didBytes = bytes(did);

        // Find the second colon (end of chain ID)
        uint256 hashStart = 8; // After "did:aid:"
        while (hashStart < didBytes.length && didBytes[hashStart] != 0x3A) {
            hashStart++;
        }

        // Unique hash starts after the second colon
        hashStart++; // Skip the colon

        // Check if hash is 66 characters (0x + 64 hex chars)
        if (hashStart + 66 > didBytes.length) {
            revert InvalidUniqueHash();
        }

        // Parse hex string to bytes32
        bytes memory hashBytes = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            uint8 high = hexCharToByte(didBytes[hashStart + 2 * i]);
            uint8 low = hexCharToByte(didBytes[hashStart + 2 * i + 1]);
            hashBytes[i] = bytes1((high << 4) | low);
        }

        // Convert to bytes32
        assembly {
            uniqueHash := mload(add(hashBytes, 32))
        }
    }

    /**
     * @notice Generates a unique hash from a public key
     * @dev Uses keccak256 to generate a unique hash from the public key
     * @param pubKey The public key (address)
     * @return uniqueHash The generated unique hash
     */
    function hashFromPubKey(address pubKey) public pure returns (bytes32 uniqueHash) {
        return keccak256(abi.encodePacked(pubKey));
    }

    /**
     * @notice Converts a hex character to its byte value
     * @param c The hex character
     * @return value The byte value
     */
    function hexCharToByte(bytes1 c) private pure returns (uint8 value) {
        if (c >= 0x30 && c <= 0x39) {
            // '0'-'9'
            return uint8(c) - 0x30;
        } else if (c >= 0x61 && c <= 0x66) {
            // 'a'-'f'
            return uint8(c) - 0x61 + 10;
        } else if (c >= 0x41 && c <= 0x46) {
            // 'A'-'F'
            return uint8(c) - 0x41 + 10;
        }
        revert InvalidUniqueHash();
    }

    /**
     * @notice Converts bytes32 to hex string
     * @dev Helper function for DID generation
     * @param value The bytes32 value to convert
     * @return The hex string representation
     */
    function bytes32ToString(bytes32 value) private pure returns (string memory) {
        bytes memory buffer = new bytes(66);
        buffer[0] = bytes1('0');
        buffer[1] = bytes1('x');

        for (uint256 i = 0; i < 32; i++) {
            uint8 b = uint8(value[i]);
            buffer[2 + 2 * i] = hexChar(b >> 4);
            buffer[2 + 2 * i + 1] = hexChar(b & 0x0F);
        }

        return string(buffer);
    }

    /**
     * @notice Converts a nibble to hex character
     * @param nibble The nibble value (0-15)
     * @return char The hex character
     */
    function hexChar(uint8 nibble) private pure returns (bytes1 char) {
        if (nibble < 10) {
            return bytes1(nibble + 0x30); // '0'-'9'
        } else {
            return bytes1(nibble - 10 + 0x61); // 'a'-'f'
        }
    }

    /**
     * @notice Checks if a chain ID is valid
     * @dev Validates common chain IDs
     * @param chainId The chain ID to check
     * @return valid Whether the chain ID is valid
     */
    function isValidChainId(string memory chainId) public pure returns (bool valid) {
        bytes memory chainIdBytes = bytes(chainId);

        // Common chain IDs
        bytes memory ethereum = bytes("ethereum");
        bytes memory sepolia = bytes("sepolia");
        bytes memory polygon = bytes("polygon");
        bytes memory base = bytes("base");
        bytes memory bsc = bytes("bsc");
        bytes memory arbitrum = bytes("arbitrum");
        bytes memory optimism = bytes("optimism");

        return
            bytesEqual(chainIdBytes, ethereum) ||
            bytesEqual(chainIdBytes, sepolia) ||
            bytesEqual(chainIdBytes, polygon) ||
            bytesEqual(chainIdBytes, base) ||
            bytesEqual(chainIdBytes, bsc) ||
            bytesEqual(chainIdBytes, arbitrum) ||
            bytesEqual(chainIdBytes, optimism);
    }

    /**
     * @notice Compares two byte arrays for equality
     * @dev Helper function for chain ID validation
     * @param a First byte array
     * @param b Second byte array
     * @return equal Whether the arrays are equal
     */
    function bytesEqual(
        bytes memory a,
        bytes memory b
    ) private pure returns (bool equal) {
        if (a.length != b.length) {
            return false;
        }

        for (uint256 i = 0; i < a.length; i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }

        return true;
    }
}
