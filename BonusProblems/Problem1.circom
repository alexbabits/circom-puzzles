pragma circom 2.1.8;

include "./node_modules/circomlib/circuits/comparators.circom";
include "./node_modules/circomlib/circuits/poseidon.circom";

// RareSkills twitter post: https://x.com/RareSkills_io/status/1811263676747591772
// Spot the Bug

template UnsafePoseidon(n) {
    signal input in;
    signal output out;

    component n2b = Num2Bits(n);
    component b2n = Bits2Num(n);
    component phash = Poseidon(1);

    n2b.in <== in;
    for (var 1 = 0; i < n; i++) {
        b2n.in[i] <== n2b.out[i];
    }

    phash.inputs[0] <== b2n.out;
    phash.out ==> out;
}

component main = UnsafePoseidon(254);


// SPOILER:









// .....











// ........











// ......


/*
There is no constraint relationship between `in` and `n`.

Anytime `in > 2^n-1`, n2b will silently overflow.

Ex: `n` = 8.  `in` = 256 (2^8)

This means we want to represent `in` number as an "8-bit" representation using n2b, which is impossible.

256 must be represented by atleast 9 bits (100000000).

n2b returns outputs "mirrored". If num in bits is 100000000 then it returns [0,0,0,0,0,0,0,0,1].

In our overflow case, n2b would return the first 8 bits mirrored which is [0,0,0,0,0,0,0,0] which represents 0, not 256!

We can fix this by doing `assert(in < (1 << n));` 

Another good safety check is to `assert(in == b2n.out);` making sure `in` survives N2B --> B2N round trip unscathed.
*/