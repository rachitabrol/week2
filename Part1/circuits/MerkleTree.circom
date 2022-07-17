pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template EvalLevel(n){//compute hashes of n-1 level fron n level hashes;
    signal input in[(n<<1)];
    signal output out[((n-1)<<1)];
    component hashes [((n-1)<<1)];
    for(var i =0;i<(n<<1);i=i+2){
        hashes[i/2] = Poseidon(2);
        hashes[i/2].inputs[0] <== in[i];
        hashes[i/2].inputs[1] <== in[i+1];
        out[i/2] <== hashes[i/2].out;
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component levels[n];
    levels[0] = EvalLevel(n);
    for(var i = 0;i<(n<<1);i++){
        levels[0].in[i]<==leaves[i];
    }
    var currLevel = n-1;
    for(var i = 1;i<n;i++){
        levels[i] = EvalLevel(currLevel);
        currLevel--;
        for(var j = 0;j<(i<<1);j++){
            levels[i].in[j] <== levels[i-1].out;
        }
    }
    root <== levels[n-1].out[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashes [n];
    component switcher [n];
    for(var i = 0;i<n;i++){
        hashes[i] = Poseidon(2);
        switcher[i] = Switcher();
        switcher[i].L <== i==0 ? leaf : hashes[i-1].out;
        switcher[i].R <== path_elements[i];
        switcher[i].sel <== path_index[i];

        hashes[i].inputs[0] <== switcher[i].outL;
        hashes[i].inputs[1] <== switcher[i].outR;
    }
    root <== hashes[n-1].out;
}