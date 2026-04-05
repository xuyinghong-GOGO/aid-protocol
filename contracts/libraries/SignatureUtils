// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SignatureUtils
 * @notice Library for signature verification and operations
 * @dev Provides utilities for ECDSA signature verification, including bidirectional verification
 */
library SignatureUtils {
    /**
     * @notice Error messages
     */
    error InvalidSignatureLength();
    error InvalidSignature();
    error InvalidRecoveredAddress();

    /**
     * @notice Validates signature length
     * @dev ECDSA signatures must be 65 bytes (r: 32, s: 32, v: 1)
     * @param signature The signature to validate
     * @return valid Whether the signature length is valid
     */
    function isValidSignatureLength(bytes memory signature) public pure returns (bool valid) {
        return signature.length == 65;
    }

    /**
     * @notice Recovers the signer address from a signature
     * @dev Uses ecrecover to recover the address from the signature
     * @param messageHash The hash of the signed message
     * @param signature The signature (r, s, v)
     * @return signer The recovered signer address
     */
    function recoverSigner(
        bytes32 messageHash,
        bytes memory signature
    ) public pure returns (address signer) {
        if (!isValidSignatureLength(signature)) {
            revert InvalidSignatureLength();
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // Adjust v if needed
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            revert InvalidSignature();
        }

        // Recover signer
        address recovered = ecrecover(messageHash, v, r, s);

        if (recovered == address(0)) {
            revert InvalidRecoveredAddress();
        }

        return recovered;
    }

    /**
     * @notice Verifies a self-signature
     * @dev Verifies that the signature is a valid self-signature of the public key
     * This is the core of bidirectional verification: the public key can verify the signature
     * @param pubKey The public key (expected signer)
     * @param signature The signature to verify
     * @return valid Whether the signature is a valid self-signature
     */
    function verifySelfSignature(
        address pubKey,
        bytes calldata signature
    ) public pure returns (bool valid) {
        if (!isValidSignatureLength(signature)) {
            return false;
        }

        // The message to be signed is the public key itself
        bytes32 messageHash = keccak256(abi.encodePacked(pubKey));

        // Add Ethereum Signed Message prefix
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Recover the signer
        address recoveredSigner = recoverSigner(ethSignedMessageHash, signature);

        // Verify that the recovered signer matches the public key
        return recoveredSigner == pubKey;
    }

    /**
     * @notice Verifies a signature
     * @dev Verifies that the signature was created by the expected signer
     * @param expectedSigner The expected signer address
     * @param messageHash The hash of the signed message
     * @param signature The signature to verify
     * @return valid Whether the signature is valid
     */
    function verifySignature(
        address expectedSigner,
        bytes32 messageHash,
        bytes calldata signature
    ) public pure returns (bool valid) {
        if (!isValidSignatureLength(signature)) {
            return false;
        }

        // Add Ethereum Signed Message prefix
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Recover the signer
        address recoveredSigner = recoverSigner(ethSignedMessageHash, signature);

        // Verify that the recovered signer matches the expected signer
        return recoveredSigner == expectedSigner;
    }

    /**
     * @notice Splits a signature into r, s, v components
     * @dev Helper function for signature manipulation
     * @param signature The signature to split
     * @return r The r component (32 bytes)
     * @return s The s component (32 bytes)
     * @return v The v component (1 byte)
     */
    function splitSignature(
        bytes calldata signature
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        if (!isValidSignatureLength(signature)) {
            revert InvalidSignatureLength();
        }

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        // Adjust v if needed
        if (v < 27) {
            v += 27;
        }
    }

    /**
     * @notice Creates a signature from r, s, v components
     * @dev Helper function for signature creation
     * @param r The r component
     * @param s The s component
     * @param v The v component
     * @return signature The combined signature
     */
    function joinSignature(
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public pure returns (bytes memory signature) {
        signature = new bytes(65);

        assembly {
            mstore(add(signature, 32), r)
            mstore(add(signature, 64), s)
            mstore8(add(signature, 96), v)
        }
    }

    /**
     * @notice Validates that s is in the lower range
     * @dev According to EIP-2, s should be <= order/2 to prevent malleability
     * @param s The s value from the signature
     * @return valid Whether s is in the valid range
     */
    function isValidSValue(bytes32 s) public pure returns (bool valid) {
        // secp256k1 order / 2
        bytes32 halfOrder = 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;
        return uint256(s) <= uint256(halfOrder);
    }

    /**
     * @notice Normalizes a signature to prevent malleability
     * @dev Adjusts v and s to ensure a canonical signature
     * @param signature The signature to normalize
     * @return normalizedSignature The normalized signature
     */
    function normalizeSignature(
        bytes calldata signature
    ) public pure returns (bytes memory normalizedSignature) {
        if (!isValidSignatureLength(signature)) {
            revert InvalidSignatureLength();
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = splitSignature(signature);

        // Adjust s to lower range if needed
        bytes32 halfOrder = 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;
        if (uint256(s) > uint256(halfOrder)) {
            // s > halfOrder, adjust s and flip v
            s = bytes32(uint256(halfOrder) * 2 - uint256(s));
            v = v == 27 ? 28 : 27;
        }

        return joinSignature(r, s, v);
    }

    /**
     * @notice Computes the message hash for signing
     * @dev Prepends the Ethereum Signed Message prefix
     * @param message The message to hash
     * @return messageHash The hash ready for signing
     */
    function toEthSignedMessageHash(
        bytes memory message
    ) public pure returns (bytes32 messageHash) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n", message.length, message)
        );
    }

    /**
     * @notice Verifies a batch of signatures
     * @dev Optimized for batch verification to save gas
     * @param signers Array of expected signers
     * @param messageHashes Array of message hashes
     * @param signatures Array of signatures
     * @return results Array of verification results
     */
    function batchVerifySignatures(
        address[] calldata signers,
        bytes32[] calldata messageHashes,
        bytes[] calldata signatures
    ) public pure returns (bool[] memory results) {
        require(
            signers.length == messageHashes.length &&
                signers.length == signatures.length,
            "Arrays length mismatch"
        );

        results = new bool[](signers.length);

        for (uint256 i = 0; i < signers.length; i++) {
            results[i] = verifySignature(signers[i], messageHashes[i], signatures[i]);
        }
    }
}
