//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint i;
        for(i=0;i<8;i++){
            hashes.push(0);
        }
        uint j = 0;
        while(i<15){
            hashes.push(PoseidonT3.poseidon([hashes[j],hashes[j+1]]));
            j=j+2;
            i++;
        }
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index<8,"Merkle Tree is Full");
        hashes[index] = hashedLeaf;

        uint levelSize = 8;
        uint currIndex = (index/2)*2+levelSize;
        //currIndex = (currIndex/2)*2;
        while(currIndex<15){
            hashes[currIndex] = PoseidonT3.poseidon([hashes[(currIndex-levelSize)],hashes[(currIndex-levelSize)+1]]);
            levelSize = levelSize/2;
            currIndex= (currIndex/2)*2 + levelSize;
        }
        index++;
        root = hashes[14];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return (verifyProof(a, b, c, input)&& root==input[0]);
    }
}
