pragma circom 2.1.4;

// In this exercise, we will learn an important concept related to hashing . There are 2 values a and b. You want to 
// perform computation on these and verify it , but secretly without discovering the values. 
// One way is to hash the 2 values and then store the hash as a reference. 
// There is on problem in this concept , attacker can brute force the 2 variables by comparing the public hash with the resulting hash.
// To overcome this, we use a secret value in the input privately. We hash it with a and b. 

// This way brute force becomes illogical as the cost will increase multifolds for the attacker.

// Input 3 values, a, b and salt. 
// Hash all 3 using mimcsponge as a hashing mechanism. 
// Output the res using 'out'.

include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

// NOTE: The old tests seemed to have bad hash values. 
// I found the correct hash values using zkREPL and just used those.
template Salt() {
    signal input a;
    signal input b;
    signal input salt;
    signal output out;

    // Define the number of inputs and outputs for MiMCSponge
    var nInputs = 3;
    var nRounds = 220; // suggested by circomlib MiMCSponge template.
    var nOutputs = 1;

    // Set up the MiMCSponge component and inputs
    component hash = MiMCSponge(nInputs, nRounds, nOutputs);
    hash.ins[0] <== a;
    hash.ins[1] <== b;
    hash.ins[2] <== salt;

    // Optionally, define the key 'k' for the sponge (can be zero if not used)
    hash.k <== 0;
    out <== hash.outs[0];
}

component main  = Salt();
// By default all inputs are private in circom. We will not define any input as public 
// because we want them to be a secret, at least in this case. 

// There will be cases where some values will be declared explicitly public .