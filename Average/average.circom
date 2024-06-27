pragma circom 2.1.8;

include "../node_modules/circomlib/circuits/comparators.circom";

// DOES NOT HAVE TESTS, I COPIED FROM: https://www.rareskills.io/post/circom-tutorial
// NOT APART OF THE ORIGINAL PUZZLE REPO.
// It's just nice to have, I haven't checked the logic.
template Average(n) {

    signal input in[n];
    signal denominator_inv;
    signal output out;

    var sum;
    for (var i = 0; i < n; i++) {
        sum += in[i];
    }

    denominator_inv <-- 1 / n;

    component eq = IsEqual();
    eq.in[0] <== 1;
    eq.in[1] <== denominator_inv * n;
	1 === eq.out;

    out <== sum * denominator_inv;

}

component main  = Average(5);