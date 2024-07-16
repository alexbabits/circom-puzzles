pragma circom 2.1.8;
include "./node_modules/circomlib/circuits/multiplexer.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

// The Circom code below sorts a list and constrains it to be sorted by checking that it is a 
// permutation of the original list and the elements are in order.
// There are 2 bugs. https://x.com/RareSkills_io/status/1808442983995392061

// Checks if the 2nd array is a permutation of the first based on the advice
template ForceIsPermutation(n) {
    signal input in1[n];
    signal input in2[n];
    signal input advice[n];

    component mux[n];

    // for each input in1...
    for (var i = 0; i < n; i++) {

        // load all of in1 into the mux
        mux[i] = Multiplexer(1,n);
        for (var j = 0; j < n; j++) {
            mux[i].inp[j][0] <== in1[j];
        }

        mux[i].sel <== advice[i]; // select the index from the advice

        in2[i] === mux[i].out[0]; // check that in2[i] == in1[advice[i]]
    }
}

template ForceIsSorted(n, bitSize) {
    signal input in[n];

    component leq[n];

    // each item is <= the next
    for (var i = 0; i < n - 1; i++) {
        leq[i] = LessEqThan(bitSize);
        leq[i].in[0] <== in[i];
        leq[i].in[1] <== in[i + 1];
        1 === leq[i].out;
    }
}

template Sort(n, bitSize) {
    signal input in[n];

    // Each index of advice corresponds to the index of output.
    // The element in the array tells where input index.
    // If input is [5,7,6] and output is [5,6,7], then advice is [0,2,1].
    // "5 was originally at 0, 6 was originally at 2, and 7 was originally at 1."
    signal output advice[n];
    signal output out[n];

    var arr[n];
    var advice_[n];

    // copy in to arr
    for (var i = 0; i < n; i++) {
        arr[i] = in[i];
        advice_[i] = i;
    }

    // selection sort arr
    for (var i = 0; i < n; i++) {

        // find minimum element and it's index
        var min_at = i;
        for (var j = i; j < n; j++) {
            if (arr[j] < arr[min_at]) {
                min_at = j;
            }
        }

        // swap with the minimum
        var temp = arr[i];
        arr[i] = arr[min_at];
        arr[min_at] = temp;

        // swap advice
        var temp2 = advice_[i];
        advice_[i] = advice_[min_at];
        advice_[min_at] = temp2;
    }

    // copy sorted arr to out
    for (var i = 0; i < n; i++) {
        out[i] <-- arr[i];
        advice[i] <-- advice_[i];
    }

    ForceIsSorted(n, bitSize)(out);
    ForceIsPermutation(n)(in, out, advice);
}

component main = Sort(10, 252);



// SPOILER BELOW:







// ...









// ...










// ...









// ...



// SOLUTION: https://x.com/RareSkills_io/status/1808810189258379470
// @agfviggiano on X: You need to check that `advice` array contains all indices from 0 to n-1 exactly and only ONCE.

// By repeating values in the adivce signal array, you could prove that an input of [9,10,8] gets sorted to become [8,8,9]...
// And this would unfortunately pass all checks! Because the output list is still constrained to contain values from the input...
// Repeated values are not handled correctly...