pragma circom 2.1.4;

// Check the range of a private variable and prove that it is within the range.
// Declare 3 input signals `a`, `lowerbound` and `upperbound`.
// If 'a' is within the range, output 1 , else output 0 using 'out'

include "../node_modules/circomlib/circuits/comparators.circom";

template Range() {
    signal input a;
    signal input lowerbound;
    signal input upperbound;
    signal output out;

    // Check if `a` is greater than or equal to lowerbound
    component geqLower = GreaterEqThan(252); // 252 to be compatible with most fields
    geqLower.in[0] <== a;
    geqLower.in[1] <== lowerbound;

    // Check if `a` is less than upperbound
    component ltUpper = LessThan(252);
    ltUpper.in[0] <== a;
    ltUpper.in[1] <== upperbound + 1;

    // a=1 and thus within the range IFF both are 1 (true).
    out <== geqLower.out * ltUpper.out;
}

component main = Range();

/* INPUT = {"a": "78", "lowerbound": "77", "upperbound": "79"} */


// Reference Templates:

/*
// N is the number of bits the input have.
// The MSF is the sign bit.
template GreaterEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = LessThan(n);

    lt.in[0] <== in[1]; // 1st input in LT is 2nd input in GT
    lt.in[1] <== in[0]+1; // 2nd input in LT is 1st input + 1 in GT

    // Simply reverses the output of LT.  
    // 0 = in[0] < in[1]
    // 1 = in[1] < in[0]
    lt.out ==> out;
}

template LessThan(n) {
    assert(n <= 252); // 252 good for most fields
    signal input in[2]; // Always takes in two values. Say in[0] = number_one, in[1] = number_two.
    signal output out;

    // n+1 to account for potential carry-over during sub/add that might require extra bit.
    component n2b = Num2Bits(n+1); 

    // 1<<n for n=3 is 1000 in binary, 8 in decimal, 2^3.
    // calculates N2B input as (number_one + (2^n) - number_two)
    // If number_one < number_two, result less than 2^n, and thus MSB will be 0. 
    // Otherwise, it will be atleast 2^n and MSB will be 1.
    // Ex: 8 + (2^3) - 5 = 8 + 8 - 5 = 11. And 11 in binary is 1011. 
    // Mirror it because N2B is silly, `[1,1,0,1]`. It grabs the last element as the MSB, which is 1.
    n2b.in <== in[0] + (1<<n) - in[1];

    // n2b.out[n] = MSB of output result from above calculation in N2B.
    // Because MSB is 1, therefore out=0, meaning in[1] < in[0]. If MSB was 0, would be vice-versa.
    // 1 = in[0] < in[1]
    // 0 = in[1] < in[0]
    out <== 1-n2b.out[n];
}
*/