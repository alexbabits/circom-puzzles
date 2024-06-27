pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Be sure to solve IntSqrt before solving this puzzle. `\` integer division`, `/` moduluo division.
// Problem: Actually calculate the sqrt now, and force it's correctness through IntSqrtOut circuit.

// Bablyonian/Heron method to compute integer square root. L = left, R = Right, M = middle, X = input number
// Ex: {L, M, R} where X is always 12. SQRT(12) = 3.46 = 3.
//
// {0, 6, 12} --> {0, 6, 6} --> 
// {0, 3, 6} --> {3, 3, 6} -->
// {3, 4.5, 6} --> {3, 4.5, 4.5} -->
// {3, 3.75, 4.5} --> {3, 3.75, 3.75}. STOP {R - 1 < 1}. Return L=3.
function intSqrtFloor(X) {

    if (X == 0) return 0;

    var R = X;
    var L = 0;

    // Continue the loop until R and L are roughly equal. Similar idea to binary search.
    while (R - L > 1) {
        
        var M = (R + L) \ 2; // M is the current middle point based on R and L.
        
        // When M^2 is larger than X, M is too large, decrease R down to M.
        if (M * M > X) {
            R = M;
        // When M^2 is smaller than X, increase L up to M.
        } else {
            L = M;
        }
    }
    return L;
}

template IntSqrtOut(n) {
    signal input in;
    signal output out;

    out <-- intSqrtFloor(in); // `in` is our X we want to solve for.

    // (b - 1)(b - 1) < a
    component lt = LessThan(n);
    lt.in[0] <== (out - 1) * (out - 1);
    lt.in[1] <== in;

    // (b + 1)(b + 1) > a
    component gt = GreaterThan(n);
    gt.in[0] <== (out + 1) * (out + 1);
    gt.in[1] <== in;

    signal check;
    check <== lt.out * gt.out;
    check === 1; // must always be 1 now, per how the tests are written
}

component main = IntSqrtOut(252);