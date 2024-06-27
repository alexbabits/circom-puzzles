pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";

// Create a Quadratic Equation( ax^2 + bx + c) verifier using the below data.
// Use comparators.circom lib to compare results if equal

// You might initially panic and think to go `b ± sqrt(b²-4ac)/2a`
// But realize we are given all the inputs including the expected result.
// As a verifier given all this information we can simply 
// calculate a result, and see if it matches the given input `res`.

template QuadraticEquation() {
    signal input x;     // x value
    signal input a;     // coeffecient of x^2
    signal input b;     // coeffecient of x 
    signal input c;     // constant c in equation
    signal input res;   // Expected result of the equation
    signal output out;  // If res is correct , then return 1 , else 0 . 

    // Piece ax^2
    signal x_squared;
    x_squared <== x * x;
    signal a_x_squared;
    a_x_squared <== a * x_squared;

    // Piece bx
    signal bx;
    bx <== b * x;

    signal calculated_res;
    calculated_res <== a_x_squared + bx + c;

    // Compare calculated result with provided result
    component isEqual = IsEqual();
    isEqual.in[0] <== calculated_res;
    isEqual.in[1] <== res;

    // out is only 1 when calculated result matches given result.
    out <== isEqual.out;
}

component main  = QuadraticEquation();

/*
Reference Templates:

template IsEqual() {
    signal input in[2];
    signal output out;

    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    isz.out ==> out;
}

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}
*/