pragma circom 2.1.8;

// Create a circuit that takes an array of four signals
// `in`and a signal s and returns is satisfied if `in`
// is the binary representation of `n`. For example:
// 
// Accept:
// 0,  [0,0,0,0]
// 1,  [1,0,0,0]
// 15, [1,1,1,1]
// 
// Reject:
// 0, [3,0,0,0]
// 
// The circuit is unsatisfiable if n > 15

template FourBitBinary() {
    signal input in[4];
    signal input n;

    // Restrict inputs to 0 or 1, the roots to `0 = x(x-1)`.
    for (var i = 0; i < 4; i++) {
        in[i] * (in[i] - 1) === 0;
    }

    // Calculate the value represented by the binary input.
    // Tests are such that in an array, MSB = rightmost, LSB = leftmost. 1 = [1,0,0,0].
    // When there is a non-zero bit, add the bits "weight" as "2^position" w.r.t. MSB.
    // (in[0] * 2^0) + (in[1] * 2^1) + (in[2] * 2^2) + (in[3] * 2^3)
    var sum = 0;
    var pow2 = 1; // 2**0
    for (var i = 0; i < 4; i++) {
        // Ex: 7 = 0111 --> [1,1,1,0]

        // sum = 0 + (1*2^0) = 1
        // pow2 = 1 * 2 = 2

        // sum = 1 + (1*2^1) = 3
        // pow2 = 2 * 2 = 4

        // sum = 3 + (1*2^2) = 7
        // pow2 = 8

        // sum = 7 + (0*8) = 7
        // pow2 = 16
        sum += in[i] * pow2;
        pow2 *= 2;
    }

    // We must get `sum` answer correct to input `n`
    sum === n;
}

component main{public [n]} = FourBitBinary();