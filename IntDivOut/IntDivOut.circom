pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Use the same constraints from IntDiv, but this
// time assign the quotient in `out`. You still need
// to apply the same constraints as IntDiv

template IntDivOut(n) {
    signal input numerator;
    signal input denominator;
    signal output out;

    // calculate quotient
    out <-- numerator \ denominator; 

    // calculate remainder
    signal remainder;
    remainder <-- numerator % denominator;

    // Remainder is less than denominator
    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;

    // Verify division
    signal product;
    product <== out * denominator + remainder;
    product === numerator;
}

component main = IntDivOut(252);
