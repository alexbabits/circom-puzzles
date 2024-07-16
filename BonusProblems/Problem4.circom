pragma circom 2.1.8;

include "./node_modules/circomlib/circuits/comparators.circom";

/*
A Quin selector is a design pattern to index an array of signals using the value of another signal as the index.
The Circom code below implements a Quin selector, but this it is underconstrained.
You know the drill. Answer will be given in 48 hours.
https://x.com/RareSkills_io/status/1813211998395552109
*/

// ELI5: Select a specific element from an array based on an index `k`. 
template UnsafeQuin(n) {
    signal input in[n]; // private input array `in` with `n` elements
    signal input k; // the index we want to select
    signal mask[n]; // intermediary signal array `mask` with `n` elements
    signal ip[n]; // intermediary signal array `ip` with `n` elements
    signal output out; // output the selected element

    // ensure k < n. (index must be smaller than array size)
    signal kLtN; 
    kLtN <== LessThan(252)([k, n]);
    kLtN === 1; 

    // compute the bit mask. (Only the k'th element should be 1).
    var acc;
    
    for (var i = 0; i < n; i++) {

        // Example: n=4, k=2, mask=[0,0,1,0], in=[10,20,30,40]

        // mask[0] = 0, acc = 0
        // mask[1] = 0, acc = 0
        // mask[2] = 1, acc = 1 * (2 + 1) = 3
        // mask[3] = 0, acc = 3

        mask[i] <-- i == k ? 1 : 0;
        mask[i] * (mask[i] - 1) === 0 // binary constraint (ensures value is either 0 or 1)
        acc += mask[i] * (i + 1); // if non-zero, it must multiply with correct index
    }

    acc - 1 === k // assert we selected the correct index... (3 - 1 = 2)

    // inner product between mask and the input
    var acc2;
    for (var i = 0; i < n; i++) {
        // ip[0] = 0 * 10 = 0, acc2 = 0
        // ip[1] = 0 * 20 = 0, acc2 = 0
        // ip[2] = 1 * 30 = 30, acc2 = 30
        // ip[3] = 0 * 40 = 0, acc2 = 30
        ip[i] <== mask[i] * in[i];
        acc2 += ip[i];
    }

    out <== acc2; // successfully grab and output 30, which is the value at index k=2.
}

component main = UnsafeQuin(4);




// SPOILER



// ..........










// ..........







/*

 * The exploit revolves around `<--`.
 * This line: `mask[i] <-- i == k ? 1 : 0;` allows the prover to
 * give ANY `k` (k<n) AND any mask elements {0,1} freely. (`<--` DOES NOT CONSTRAIN mask[i])
 * We get to completely ignore `i == k ? 1 : 0`!
 * This allows masks like [1,1,0,0] to be processed.
 * SHOULD ONLY ALLOW ONE 1 for a mask array, but this has multiple!
 * Let n=4, k=2, in=[10,20,69,40], mask=[1,1,0,0]. Then we get: acc=3. acc2=30. 
 * It outputs 30, when k=2 index actually corresponds to 69!
 *
 * What this would look like in practice, is someone generating a witness
 * and then maliciously altering the binary data for the `mask[]`
 * Allowing for a valid proof with a BAD witness because `mask[]` is malicious.
 * More here: https://www.rareskills.io/post/underconstrained-circom
 *
 * This seems to be a safer QuinSelector:
 * https://github.com/darkforest-eth/circuits/blob/9033eaf72388cf3f7721eb2564fd83a12818dc0e/perlin/QuinSelector.circom#L1-#L30

template QuinSelector(choices) {
    signal input in[choices];
    signal input index;
    signal output out;
    
    // Ensure that index < choices
    component lessThan = LessThan(4);
    lessThan.in[0] <== index;
    lessThan.in[1] <== choices;
    lessThan.out === 1;

    component calcTotal = CalculateTotal(choices);
    component eqs[choices];

    // For each item, check whether its index equals the input index.
    for (var i = 0; i < choices; i ++) {
        eqs[i] = IsEqual();
        eqs[i].in[0] <== i;
        eqs[i].in[1] <== index;

        // eqs[i].out is 1 if the index matches. As such, at most one input to
        // calcTotal is not 0.
        calcTotal.in[i] <== eqs[i].out * in[i];
    }

    // Returns 0 + 0 + 0 + item
    out <== calcTotal.out;
}

*/