// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DeNodeOne is Ownable {
    struct Node {
        address owner;
        uint256 stakeAmount;
        uint256 reputation;
        uint256 rewards;
        bool active;
    }

    uint256 public minimumStake;
    uint256 public totalStaked;
    uint256 public nodeCount;

    mapping(uint256 => Node) private nodes;
    mapping(address => uint256) private ownerToNodeId;

    event NodeRegistered(uint256 indexed nodeId, address indexed owner, uint256 stakeAmount);
    event StakeAdded(uint256 indexed nodeId, uint256 amount);
    event RewardsDistributed(uint256 indexed nodeId, uint256 amount);
    event RewardsClaimed(uint256 indexed nodeId, address indexed owner, uint256 amount);
    event NodeDeactivated(uint256 indexed nodeId);

    modifier onlyNodeOwner(uint256 nodeId) {
        require(nodes[nodeId].owner == msg.sender, "Not node owner");
        _;
    }

    constructor(uint256 _minimumStake) {
        minimumStake = _minimumStake;
        nodeCount = 0;
        totalStaked = 0;
    }

    /**
     * @dev Registers a new node by staking ETH (must meet minimum stake)
     */
    function registerNode() external payable {
        require(msg.value >= minimumStake, "Stake below minimum");
        require(ownerToNodeId[msg.sender] == 0, "Node already registered");

        nodeCount++;
        nodes[nodeCount] = Node({
            owner: msg.sender,
            stakeAmount: msg.value,
            reputation: 0,
            rewards: 0,
            active: true
        });

        ownerToNodeId[msg.sender] = nodeCount;
        totalStaked += msg.value;

        emit NodeRegistered(nodeCount, msg.sender, msg.value);
    }

    /**
     * @dev Adds additional stake to an existing node
     */
    function addStake() external payable {
        uint256 nodeId = ownerToNodeId[msg.sender];
        require(nodeId != 0, "No node owned");
        require(nodes[nodeId].active, "Node inactive");
        require(msg.value > 0, "Must send ether");

        nodes[nodeId].stakeAmount += msg.value;
        totalStaked += msg.value;

        emit StakeAdded(nodeId, msg.value);
    }

    /**
     * @dev Distributes rewards to nodes (owner only)
     * @param nodeId The node to reward
     * @param amount Reward amount to add
     */
    function distributeReward(uint256 nodeId, uint256 amount) external onlyOwner {
        require(nodes[nodeId].active, "Node inactive");
        nodes[nodeId].rewards += amount;

        emit RewardsDistributed(nodeId, amount);
    }

    /**
     * @dev Node owner claims accumulated rewards
     */
    function claimRewards() external {
        uint256 nodeId = ownerToNodeId[msg.sender];
        require(nodeId != 0, "No node owned");
        Node storage node = nodes[nodeId];
        require(node.rewards > 0, "No rewards to claim");

        uint256 rewardAmount = node.rewards;
        node.rewards = 0;

        payable(node.owner).transfer(rewardAmount);

        emit RewardsClaimed(nodeId, msg.sender, rewardAmount);
    }

    /**
     * @dev Owner can deactivate a node (e.g., for inactivity or violation)
     */
    function deactivateNode(uint256 nodeId) external onlyOwner {
        nodes[nodeId].active = false;
        emit NodeDeactivated(nodeId);
    }

    /**
     * @dev View node details
     */
    function getNode(uint256 nodeId) external view returns (
        address owner,
        uint256 stakeAmount,
        uint256 reputation,
        uint256 rewards,
        bool active
    ) {
        Node storage node = nodes[nodeId];
        return (node.owner, node.stakeAmount, node.reputation, node.rewards, node.active);
    }

    /**
     * @dev Withdraw function to receive ETH rewards: fallback
     */
    receive() external payable {}
}
// 
End
// 
