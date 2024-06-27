pragma circom 2.1.8;

// Create a circuit that takes an array of signals `in[n]` and
// a signal k. The circuit should return 1 if `k` is in the list
// and 0 otherwise. This circuit should work for an arbitrary length of `in`.

include "../node_modules/circomlib/circuits/comparators.circom";

template HasAtLeastOne(n) {
    signal input in[n];
    signal input k;
    signal output out;

    signal equalChecks[n];
    component isEqual[n];

    signal runningSum[n + 1];
    runningSum[0] <== 0;

    // Check each element for equality with k
    for (var i = 0; i < n; i++) {
        isEqual[i] = IsEqual();
        isEqual[i].in[0] <== in[i];
        isEqual[i].in[1] <== k;
        equalChecks[i] <== isEqual[i].out;

        // Add to running sum
        runningSum[i+1] <== runningSum[i] + equalChecks[i];
    }

    component isz = IsZero();
    isz.in <== runningSum[n];

    // `k` is inside array `in[n]` when `isz.out` is 0, and so `out` is 1,
    // meaning `runningSum` is NOT zero, and thus we found atleast one match.
    out <== 1 - isz.out;
}

component main = HasAtLeastOne(4);