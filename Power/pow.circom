pragma circom 2.1.4;

// Problem: Make a signal array `a` where `a[0]` is the base and `a[1]` is the exponent.
// Calculate `a[0] ** a[1]` and output it as `c`.

include "../node_modules/circomlib/circuits/bitify.circom";

// (LMAO I made it way more complicated than it needed to be)
// Simple solution is shown below this one
// From: https://github.com/socathie/circomlib-matrix/blob/d41bae31115fed35aea9294d9dbf55354b8bbc5f/circuits/power.circom#L1-#L19


/*
// `&` returns 1 when both bits are 1, else 0. With `x & 1`, the 1 is LSB representing 0001.
// `>>` shifts bits to the right. For example, 0011 >> 0 = 0011. 0011 >> 1 = 0001. 0011 >> 2 = 0000.

// `n` determines how many bits we are using to represent the input `in`.
// `lc1` is the "linaer combination" used to reconstruct the original number and make sure it matches our input in the end.
// `e2` is exponents of power 2. We start at 2**0 = 1.
// `out[0]` represents the LSB, mirrored to the actual bit representation.

// With `n` = 4 and `in` = 3, `out` = [1, 1, 0, 0] to represent 0011.
// 3 in binary is 0011 with 4 bit representation (0*2^3 + 0*2^2 + 1*2^1 + 1*2^0). LSB = rightmost bit. MSB = leftmost bit.

template Num2Bits(n) {

   signal input in; 
   signal output out[n];
   var lc1 = 0; 
   var e2 = 1;

   for (var i = 0; i < n; i++) {
      out[i] <-- (in >> i) & 1; 
      out[i] * (out[i] - 1) === 0;
      lc1 += out[i] * e2; 
      e2 = e2 + e2; 
   }

   lc1 === in;
}
*/

// Uses Binary Exponentiation algorithm
// Maximum output value is {uint256.max, 2^256-1, 1.15x10^77}. Does not "revert" on overflow.
// N is the number of bits used to represent the binary value of the exponent. 
// Maximum exponent value = 2^N-1. When N=6, maximum input exponent is 2^6-1 = 63.
// Commented example with (base a[0] = 5), (power a[1] = 3). 5**3 = 125.
template Pow() {
   var N = 6; 
   signal input a[2];
   signal output c;

   // Instantiate Num2Bits template for N, let input be our exponent which we need to 'bitify'.
   component bits = Num2Bits(N);
   bits.in <== a[1]; 

   // Create partial results array of length 7, first element is 1 representing (base^0 = 1).
   signal partials[N + 1];
   partials[0] <== 1;

   // Precompute powers. Fills up powers array with [5^1, 5^2, 5^4, 5^8, 5^16, 5^32]
   signal powers[N];
   powers[0] <== a[0];
   for (var i = 1; i < N; i++) {
      powers[i] <== powers[i - 1] * powers[i - 1];
   }

   // Calculate answer. `temp` array needed to fix non-quadratic error from too much multiplication.
   // Exponent's bits are evaluated from LSB (first element in array) to MSB (last element in array).
   // 3 in binary with 6 bit representation is 000011, which is [1,1,0,0,0,0] in Num2Bits output array.
   // Computes (1*5^1 + 1*5^2 + 0*5^4 + 0*5^8 + 0*5^16 + 0*5^32) = 5^3 = 125.
   signal temp[N];
   for (var i = 0; i < N; i++) {
      // temp[0] = 1 * 5 = 5
      // partials[1] = 1 * (5 - 1) + 1 = 5.

      // temp[1] = 5 * 5^2 = 5^3
      // partials[2] = 1 * (5^3 - 5) + 5 = 125

      // temp[2-5] continues to be computed but doesn't matter.
      // partials[3-6] stays the same as partials[2]
      temp[i] <== partials[i] * powers[i];
      partials[i + 1] <== bits.out[i] * (temp[i] - partials[i]) + partials[i];
   }

   c <== partials[N]; // Last element at index 7. [0,1,2,3,4,5,6]
}

component main = Pow();

// Copy paste this input exactly as-is into zkREPL and run to see correct result.
/* INPUT = {"a": ["3", "7"]} */


// THE SIMPLE SOLUTION:
template power (p) {
   signal input a;
   signal output out;

   assert(p > 0);

   signal prod[p];

   prod[0] <== a;
    
   for (var i=1; i < p; i++) {
      prod[i] <== prod[i-1] * a;
   }

   out <== prod[p-1];
}