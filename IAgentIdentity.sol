// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IAgentIdentity
 * @notice Interface for Agent Identity Contract (Optimized Version)
 * @dev Defines the interface for managing Agent DID registration, verification, and queries
 */
interface IAgentIdentity {
    /**
     * @notice Agent identity information (Optimized storage layout)
     * @dev Contains all essential information for an Agent's identity with packed storage
     * @param did Agent DID (Decentralized Identifier)
     * @param pubKey Public key of the Agent (Ethereum address format)
     * @param signature Self-signature of the public key (for bidirectional verification)
     * @param ownerHash Hash of owner information (for compliance tracing)
     * @param timestamp Registration timestamp (uint64 for gas efficiency, supports up to year 292)
     * @param isActive Whether the identity is active (bool packed with other small types)
     */
    struct AgentIdentity {
        string did;
        address pubKey;
        bytes signature;
        bytes32 ownerHash;
        uint64 timestamp;
        bool isActive;
    }

    /**
     * @notice Emitted when a new Agent is registered
     * @custom:gas Optimized event with indexed parameters
     * @param did DID of the registered Agent
     * @param pubKey Public key of the Agent
     * @param ownerHash Hash of owner information
     * @param timestamp Registration timestamp (uint64)
     */
    event AgentRegistered(
        string indexed did,
        address indexed pubKey,
        bytes32 ownerHash,
        uint64 timestamp
    );

    /**
     * @notice Emitted when identity status changes
     * @custom:gas Optimized event with indexed parameter
     * @param did DID of the Agent
     * @param isActive New active status
     */
    event IdentityStatusChanged(string indexed did, bool isActive);

    /**
     * @notice Emitted when multiple agents are registered in batch
     * @custom:gas Batch registration event for tracking
     * @param caller Address of the caller
     * @param count Number of agents registered
     * @param timestamp Batch registration timestamp
     */
    event BatchRegistered(address indexed caller, uint256 count, uint64 timestamp);

    /**
     * @notice Registers a new Agent identity (Optimized)
     * @dev Validates DID, public key, and self-signature before registration
     * @custom:gas Uses optimized storage writes and validation order
     * @param did The DID of the Agent to register
     * @param pubKey The public key of the Agent
     * @param signature The self-signature of the public key
     * @param ownerHash The hash of owner information for compliance
     * @return success Whether the registration was successful
     */
    function registerAgent(
        string calldata did,
        address pubKey,
        bytes calldata signature,
        bytes32 ownerHash
    ) external returns (bool success);

    /**
     * @notice Registers multiple Agents in a single transaction
     * @dev Reduces gas cost per registration through batch processing
     * @custom:gas Gas efficient for bulk registrations (~30-40% savings per agent)
     * @param dids Array of DIDs to register
     * @param pubKeys Array of public keys corresponding to each DID
     * @param signatures Array of self-signatures corresponding to each DID
     * @param ownerHashes Array of owner hashes corresponding to each DID
     * @return success Whether all registrations were successful
     * @return count Number of successfully registered agents
     */
    function registerAgentsBatch(
        string[] calldata dids,
        address[] calldata pubKeys,
        bytes[] calldata signatures,
        bytes32[] calldata ownerHashes
    ) external returns (bool success, uint256 count);

    /**
     * @notice Retrieves identity information by DID
     * @custom:gas Uses memory loading for efficiency
     * @param did The DID to query
     * @return identity The Agent identity information
     */
    function getIdentity(string calldata did) external view returns (AgentIdentity memory identity);

    /**
     * @notice Retrieves DID by public key
     * @param pubKey The public key to query
     * @return did The DID associated with the public key
     */
    function getDIDByPubKey(address pubKey) external view returns (string memory did);

    /**
     * @notice Checks if a DID is registered
     * @param did The DID to check
     * @return registered Whether the DID is registered
     */
    function isRegistered(string calldata did) external view returns (bool registered);

    /**
     * @notice Checks if a public key is already used
     * @param pubKey The public key to check
     * @return used Whether the public key is already used
     */
    function isPubKeyUsed(address pubKey) external view returns (bool used);

    /**
     * @notice Sets the active status of an identity
     * @dev Only the owner (public key owner) can call this function
     * @custom:gas Optimized status change operation
     * @param did The DID to update
     * @param isActive The new active status
     */
    function setIdentityActive(string calldata did, bool isActive) external;

    /**
     * @notice Deactivates an identity
     * @dev Only the owner (public key owner) can call this function
     * @custom:gas Optimized deactivation operation
     * @param did The DID to deactivate
     */
    function deactivateIdentity(string calldata did) external;

    /**
     * @notice Returns the total number of registered Agents
     * @return count Total number of registered Agents
     */
    function getTotalRegistered() external view returns (uint256 count);

    /**
     * @notice Returns the contract version
     * @return version Contract version number
     */
    function getVersion() external pure returns (uint8 version);

    /**
     * @notice Validates a DID format
     * @param did The DID to validate
     * @return valid Whether the DID format is valid
     */
    function isValidDID(string calldata did) external pure returns (bool valid);

    /**
     * @notice Verifies a self-signature
     * @dev Verifies that the signature is a valid self-signature of the public key
     * @param pubKey The public key
     * @param signature The signature to verify
     * @return valid Whether the signature is valid
     */
    function verifySelfSignature(
        address pubKey,
        bytes calldata signature
    ) external pure returns (bool valid);
}
