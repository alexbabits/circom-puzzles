pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if
// in[0] is the floor of the integer integer
// sqrt of in[1]. For example:
// 
// int[2, 5] accept
// int[2, 9] reject
// int[3, 9] accept
//
// If b is the integer square root of a, where b = in[0] and a = in[1], 
// then the following must be true:
//
// (b - 1)(b - 1) < a
// (b + 1)(b + 1) > a
// 
// be careful when verifying that you 
// handle the corner case of overflowing the 
// finite field. You should validate integer
// square roots, not modular square roots
//
// Meaning, (b+1)^2 should not exceed the field value?
// (idc, mostly use 21888242871839275222246405745257275088548364400416034343698204186575808495617 anyway?)

template IntSqrt(n) {
    signal input in[2];
    signal output out;

    // (b - 1)(b - 1) < a
    component lt = LessThan(n);
    lt.in[0] <== (in[0] - 1) * (in[0] - 1);
    lt.in[1] <== in[1];

    // (b + 1)(b + 1) > a
    component gt = GreaterThan(n);
    gt.in[0] <== (in[0] + 1) * (in[0] + 1);
    gt.in[1] <== in[1];

    // `out` needs to match 0 or 1 where necessary (0 for failure, 1 for success) per the tests. 
    out <== lt.out * gt.out;
}

component main = IntSqrt(252);

// for [2,9]:
// (b + 1)(b + 1) > a = 9 > 9, the LT will output 0 because it's just (9 + 2^252 - 9), MSB is 1 so LT output 0.
// Which means GT will output 0. Which means our `out` should be 0 and "fail" correctly.