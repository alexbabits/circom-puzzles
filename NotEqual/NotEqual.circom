pragma circom 2.1.4;

// Input : a , length of 2. Output : c. Check that a[0] is NOT equal to a[1], if not equal, output 1, else output 0.

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}

template NotEqual() {
    signal input a[2];
    signal output c;

    component isz = IsZero();

    // When subtraction result is 0, we know numbers are equal, and this will return `1` for isz.out.
    // When subtraction result is non-zero, we know numbers are not equal, and this will return `0` for isz.out.
    isz.in <== a[0] - a[1];

    // We need c to return 1 when isz.out is 0, and c to return 0 when isz.out is 1.
    // We can't use a ternary directly like `c <== isz.out = 0 ? 1 : 0`, but we can do it simply like this:
    c <== 1 - isz.out;
}

component main = NotEqual();