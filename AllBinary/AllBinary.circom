pragma circom 2.1.8;

// Create constraints that enforces all signals in `in` are binary, i.e. 0 or 1.

// We need an equation where the only solutions are 0 or 1.
// x(1-x) = 0
// x - x^2 = 0

template AllBinary(n) {
    signal input in[n];

    for (var i = 0; i < n; i++) {
        in[i] * (in[i] - 1) === 0;
    }

}

component main = AllBinary(4);
