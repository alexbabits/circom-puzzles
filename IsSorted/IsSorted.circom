pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Write a circuit that constrains the 4 input signals to be
// sorted. Sorted means the values are non decreasing starting
// at index 0. The circuit should not have an output.

template IsSorted() {
    signal input in[4];

    // LessEqThan to check if each element is less than or equal to the next
    // Creates 3 lte components for each pair of adjacent elements.
    // We don't need 4 componenets because "comparisons" require N-1 as set size to fully check everything. 
    // Maybe even (N/2 + 1) set size is sufficient if algorithm is maximally efficient.
    component lte[3];

    for (var i = 0; i < 3; i++) {
        lte[i] = LessEqThan(252);  // can handle massive numbers with 252 bits.
        lte[i].in[0] <== in[i];
        lte[i].in[1] <== in[i + 1];

        // Every iteration must be true (1) which means
        // Elements of smaller index are always less than or equal to elements of higher index.
        lte[i].out === 1;
    }
}

component main = IsSorted();

// Reference templates:

/*
// N is the number of bits the input  have.
// The MSF is the sign bit.
template LessEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = LessThan(n);

    lt.in[0] <== in[0];
    lt.in[1] <== in[1]+1;
    lt.out ==> out;
}

template LessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b = Num2Bits(n+1);

    n2b.in <== in[0]+ (1<<n) - in[1];

    out <== 1-n2b.out[n];
}
*/