pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Write a circuit that returns true when at least one
// element is 1. It should return false if any elements
// are 0. It should be unsatisfiable if any of the inputs are not 0 or not 1.

template OR() {
    signal input a;
    signal input b;
    signal output out;

    out <== a + b - a * b;
}

// Returns 1 when at least 1 element is 1, 0 otherwise. Ensures all inputs are binary.
template MultiOR(n) {
    signal input in[n];
    signal output out;
    component or1;
    component or2;
    component ors[2];

    // Restrict all elements in `in` to be binary 0 or 1.
    for (var i = 0; i < n; i++) {
        in[i] * (in[i] - 1) === 0;
    }

    // 1 input
    if (n==1) {
        out <== in[0];

    // 2 inputs
    } else if (n==2) {
        or1 = OR();
        or1.a <== in[0];
        or1.b <== in[1];
        out <== or1.out;

    // 3 or more inputs...
    // - Split the input array into two parts (n1 and n2).
    // - Recursively apply MultiOR to each part.
    // - Use OR to combine the results of the two recursive calls.
    // Example with [0,1,0,1] it breaks it into [0,1] and [0,1] because n1=2, n2=2.
    // Evaluates both of those to be 1, and apply OR to [1,1] which is 1.
    /*
        [0, 1, 0, 1]
           /     \
       [0, 1]   [0, 1]
         |         |
         1         1
           \     /
             OR
              |
              1
    */
    } else {
        or2 = OR();
        var n1 = n\2;
        var n2 = n - n\2;
        ors[0] = MultiOR(n1);
        ors[1] = MultiOR(n2);
        var i;
        for (i=0; i<n1; i++) ors[0].in[i] <== in[i];
        for (i=0; i<n2; i++) ors[1].in[i] <== in[n1+i];
        or2.a <== ors[0].out;
        or2.b <== ors[1].out;
        out <== or2.out;
    }
}    

component main = MultiOR(4);