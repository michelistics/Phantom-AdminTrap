// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract Trap is ITrap {
    // ============================
    // CONFIG
    // ============================

    address public constant TARGET =
        0x0000000000000000000000000000000000000000; // replace

    // EIP-1967 admin slot
    bytes32 constant ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    bytes32 constant GUARDIAN_SLOT = keccak256("guardian");
    bytes32 constant OPERATOR_SLOT = keccak256("operator");

    // ============================
    // COLLECT
    // ============================

    /// returns:
    /// (owner, admin, guardian, operator, blockNumber)
    function collect() external view override returns (bytes memory) {
        bytes32 owner;
        bytes32 admin;
        bytes32 guardian;
        bytes32 operator;

        assembly {
            owner := extcodehash(TARGET)
        }

        assembly {
            admin := sload(ADMIN_SLOT)
            guardian := sload(GUARDIAN_SLOT)
            operator := sload(OPERATOR_SLOT)
        }

        return abi.encode(
            owner,
            admin,
            guardian,
            operator,
            block.number
        );
    }

    // ============================
    // SHOULD RESPOND
    // ============================

    function shouldRespond(bytes[] calldata samples)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (
            samples.length < 2 ||
            samples[0].length == 0 ||
            samples[1].length == 0
        ) {
            return (false, bytes(""));
        }

        (
            bytes32 aOwner,
            bytes32 aAdmin,
            bytes32 aGuardian,
            bytes32 aOperator,
            uint256 aBlk
        ) = abi.decode(samples[0], (bytes32, bytes32, bytes32, bytes32, uint256));

        (
            bytes32 bOwner,
            bytes32 bAdmin,
            bytes32 bGuardian,
            bytes32 bOperator,
            uint256 bBlk
        ) = abi.decode(samples[1], (bytes32, bytes32, bytes32, bytes32, uint256));

        bool aLatest = aBlk >= bBlk;

        bytes32 latestOwner    = aLatest ? aOwner    : bOwner;
        bytes32 prevOwner      = aLatest ? bOwner    : aOwner;

        bytes32 latestAdmin    = aLatest ? aAdmin    : bAdmin;
        bytes32 prevAdmin      = aLatest ? bAdmin    : aAdmin;

        bytes32 latestGuardian = aLatest ? aGuardian : bGuardian;
        bytes32 prevGuardian   = aLatest ? bGuardian : aGuardian;

        bytes32 latestOperator = aLatest ? aOperator : bOperator;
        bytes32 prevOperator   = aLatest ? bOperator : aOperator;

        // owner flip
        if (latestOwner != prevOwner) {
            return (true, abi.encode("OWNER_CHANGED"));
        }

        // admin flip
        if (latestAdmin != prevAdmin) {
            return (true, abi.encode("ADMIN_CHANGED"));
        }

        // activation of latent roles
        if (prevGuardian == bytes32(0) && latestGuardian != bytes32(0)) {
            return (true, abi.encode("GUARDIAN_ACTIVATED"));
        }

        if (prevOperator == bytes32(0) && latestOperator != bytes32(0)) {
            return (true, abi.encode("OPERATOR_ACTIVATED"));
        }

        return (false, bytes(""));
    }
}
