? Function 1: Register a new node
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

    ??? Function 3: Transfer admin ownership
    function transferAdmin(address _newAdmin) external {
        require(msg.sender == admin, "Only admin can transfer");
        require(_newAdmin != address(0), "Invalid address");

        emit OwnershipTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }
}
// 
update
// 
