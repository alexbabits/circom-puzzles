pragma circom 2.1.8;

// Create a circuit that takes an array of signals `in` and
// returns 1 if all of the signals are 1. If any of the
// signals are 0 return 0. If any of the signals are not
// 0 or 1 the circuit should not be satisfiable.
// integer division in Circom is `\`. Modulo division is `/`
template AND() {
    signal input a;
    signal input b;
    signal output out;

    out <== a*b;
}

// Returns 1 IFF all inputs are 1, 0 otherwise. Ensures all inputs are binary.
// (Copied from circomlib and binary restriction added). Saves compute on 1 or 2 inputs.
template MultiAND(n) {
    signal input in[n];
    signal output out;
    component and1;
    component and2;
    component ands[2];

    // Restrict all elements in `in` to be binary 0 or 1.
    for (var i = 0; i < n; i++) {
        in[i] * (in[i] - 1) === 0;
    }

    // 1 input
    if (n==1) {
        out <== in[0];

    // 2 inputs
    } else if (n==2) {
        and1 = AND();
        and1.a <== in[0];
        and1.b <== in[1];
        out <== and1.out;

    // 3 or more inputs...
    // - Split the input array into two parts (n1 and n2).
    // - Recursively apply MultiAND to each part.
    // - Use AND to combine the results of the two recursive calls.
    // Example with [0,1,1,1] it breaks it into [0,1] and [0,1] because n1=2, n2=2.
    // Evaluates both of those to be 1, and apply OR to [1,1] which is 1.
    /*
        [0, 1, 1, 1]
           /     \
       [0, 1]   [1, 1]
         |         |
         0         1
           \     /
             AND
              |
              0
    */
    } else {
        and2 = AND();
        var n1 = n\2;
        var n2 = n - n\2;
        ands[0] = MultiAND(n1);
        ands[1] = MultiAND(n2);
        var i;
        for (i=0; i<n1; i++) ands[0].in[i] <== in[i];
        for (i=0; i<n2; i++) ands[1].in[i] <== in[n1+i];
        and2.a <== ands[0].out;
        and2.b <== ands[1].out;
        out <== and2.out;
    }
}

component main = MultiAND(4);