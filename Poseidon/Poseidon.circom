pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

// Import poseidon.circom. 
// Input 4 variables 'a','b','c','d' and output variable 'out'.
// Hash all the 4 inputs using poseidon and output it.
template poseidon() {
   signal input a;
   signal input b;
   signal input c;
   signal input d;
   signal output out;

   // Create inputs array
   signal inputs[4];
   inputs[0] <== a;
   inputs[1] <== b;
   inputs[2] <== c;
   inputs[3] <== d;

   // Use template "Poseidon" which is the actual hashing function.
   component poseidon = Poseidon(4); 
   for (var i = 0; i < 4; i++) {
      poseidon.inputs[i] <== inputs[i];
   }

   out <== poseidon.out;
}

component main = poseidon();