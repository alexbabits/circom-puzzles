pragma circom 2.1.4;

// Input : 'a',array of length 2. Output : 'c 
// Using a forLoop , add a[0] and a[1], 4 times in a row .
template ForLoop() {
    signal input a[2]; // array with 2 values. Length 2.
    signal output c;

    signal sum[5]; // array with 5 values. Length 5.

    sum[0] <== 0; // Explicitly initialize sum[0] to 0.

    for (var i = 0; i < 4; i++) {
        // sum[1] <== sum[0] + a[0] + a[1];
        // sum[2] <== sum[1] + a[0] + a[1];
        // sum[3] <== sum[2] + a[0] + a[1];
        // sum[4] <== sum[3] + a[0] + a[1];
        sum[i + 1] <== sum[i] + a[0] + a[1];
    }

    c <== sum[4]; // The last index in the `sum` array represents the total sum.
}  

component main = ForLoop();