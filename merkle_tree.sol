pragma solidity ^0.8.0;

contract merkle {

    mapping (uint => uint) public roots;

    function _addValue(uint value, uint i) internal {
        if (roots[i] == 0) {
            roots[i] = value;
        }
        else {
            roots[i+1]=_addValue(i+1, hash(value, roots[i]));
            roots[i] = 0;
        }
    }

    function addValue(uint value) public {
        _addValue(value, 0);
    }


    function verifyer(uint[] path) public returns(bool result) {
        uint tempRoot = path[0];
        for (uint i; i < path.length - 1; i++) {
            tempRoot=hash(tempRoot, path[i+1]);
        }
        if (tempRoot == roots[path.length - 1]){
            result = true;
        }
        else {
            result = false;
        }
    }

    mapping(address => uint) userInfos;


    function addInfos(string s1, string s2, string s3, string s4, address _to) external {
        uint l1 = keccak256(abi.encodePacked(s1, s2));
        uint l2 = keccak256(abi.encodePacked(s3, s4));
        uint root = keccak256(abi.encodePacked(l1, l2));
        userInfos[_to] = root;
    
    }

}

pragma solidity ^0.8.13;

contract MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}

contract TestMerkleProof is MerkleProof {
    bytes32[] public hashes;

    constructor() {
        string[4] memory transactions = [
            "sex",
            "age",
            "name",
            "id"
        ];

        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint n = transactions.length;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }
}