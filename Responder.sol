// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ShadowAdminResponder {
    address public owner;
    address public caller;

    event AuthorityAlert(
        string reason,
        uint256 blockNumber,
        address triggeredBy
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyCaller() {
        require(msg.sender == caller || msg.sender == owner, "not-caller");
        _;
    }

    function setCaller(address c) external {
        require(msg.sender == owner, "!owner");
        caller = c;
    }

    function respond(bytes calldata payload) external onlyCaller {
        string memory reason = abi.decode(payload, (string));
        emit AuthorityAlert(reason, block.number, msg.sender);
    }
}
