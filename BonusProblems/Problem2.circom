pragma circom 2.1.8;

include "./node_modules/circomlib/circuits/comparators.circom";

// https://x.com/RareSkills_io/status/1809180423991533659

// The following circuit proves that `out` is the integer division result of `num` and `den`.
// Can you spot the bugs? (more than one!).
// If so, show the inputs that lead to an unexpected output.

template IntDivOut(n) {
    signal input num;
    signal input den;

    signal output out;
    signal output r;
    signal t;

    out <-- num \ den; // integer division
    r <-- num % den;

    den * out + r === num;
    t <== LessThan(252)([r, out]);
    r === 1;
}

component main = IntDivOut(252);






// SPOILER:





// ......












// ......



// Division by 0 is a problem:

/*
    component isNonZero = IsZero();
    isNonZero.in <== den;
    1 - isNonZero.out === 1;
*/



// You want the remainder to be less than the denominator, not eq 1.

/*
    component ltCheck = LessThan(n);
    ltCheck.in[0] <== r;
    ltCheck.in[1] <== den;
    ltCheck.out === 1;
*/

// `t` signal and comparison can be removed, it's uselessly checking the `r` with `out` which makes no sense.
// `t <== LessThan(252)([r, out]);` [SNIP]


// Check that `num` and `den` are within valid range for the given field.
// `den * out` could overflow leading to incorrect results.