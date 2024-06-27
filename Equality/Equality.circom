pragma circom 2.1.4;

// Finished: IsZero & Equality of 3 numbers.

template IsZero() {
   signal input in;
   signal output out;
   signal inv;

   // When `in` is not zero, we compute `1/in`, which is the inverse. If it is 0, `inv` is simply 0. Note the `<--`
   // This computes the "multiplicative inverse" `inv`.
   inv <-- in!=0 ? 1/in : 0;

   // Definitionally: `in * inv = 1` and `-in * inv = -1`. Therefore, out = 0 when `in` is non-zero. 
   // When `in` is 0, `inv` is also zero, therefore out = 1 when `in` is 0.
   // For {in, out} this correctly outputs {0, 1} and {non-zero, 0}. 
   out <== -in*inv +1;

   // When `in` is 0, this must be 0. When `in` is non-zero, `out` is zero. So the product should ALWAYS be zero.
   in*out === 0;
}

template Equality() {
   signal input a[3];
   signal output c;

   component isz01 = IsZero();
   component isz12 = IsZero();

   // See if the difference of the elements is 0 by using the subtraction result as the `in` input into IsZero();
   // isz01 and isz12 will be `1` if IsZer() outputs 1, meaning the subtraction is 0, meaning the elements are equal
   // Otherwise, isz01 and isz12 will be 0 if the subtraction is non-zero.
   isz01.in <== a[0] - a[1];
   isz12.in <== a[1] - a[2];

   // `c` should be 1 IFF both `isz01` and `isz12` are 1. If either are 0, this successfully outputs 0, meaning
   // one or more elements do not match.
   c <== isz01.out * isz12.out;
}

component main = Equality();