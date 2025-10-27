// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DeNodeOne
 * @dev A decentralized node registration and management system for blockchain networks.
 */

contract DeNodeOne {
    struct Node {
        address owner;
        string nodeName;
        uint256 stake;
        bool isActive;
    }

    mapping(address => Node) public nodes;
    uint256 public totalNodes;
    address public admin;

    event NodeRegistered(address indexed owner, string nodeName, uint256 stake);
    event NodeDeactivated(address indexed owner);
    event OwnershipTransferred(address indexed oldAdmin, address indexed newAdmin);

    constructor() {
        admin = msg.sender;
    }

    // 🟢 Function 1: Register a new node
    function registerNode(string calldata _nodeName) external payable {
        require(msg.value >= 0.01 ether, "Minimum stake: 0.01 ETH");
        require(!nodes[msg.sender].isActive, "Node already registered");

        nodes[msg.sender] = Node({
            owner: msg.sender,
            nodeName: _nodeName,
            stake: msg.value,
            isActive: true
        });

        totalNodes++;
        emit NodeRegistered(msg.sender, _nodeName, msg.value);
    }

    // 🔴 Function 2: Deactivate your node
    function deactivateNode() external {
        Node storage node = nodes[msg.sender];
        require(node.isActive, "Node not active");

        node.isActive = false;
        payable(msg.sender).transfer(node.stake);
        emit NodeDeactivated(msg.sender);
    }

    // 🧑‍💼 Function 3: Transfer admin ownership
    function transferAdmin(address _newAdmin) external {
        require(msg.sender == admin, "Only admin can transfer");
        require(_newAdmin != address(0), "Invalid address");

        emit OwnershipTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }
}
