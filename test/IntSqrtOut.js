const chai = require('chai');
const {
    wasm
} = require('circom_tester');
const path = require("path");
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);
const chaiAsPromised = require("chai-as-promised");
const wasm_tester = require("circom_tester").wasm;

chai.use(chaiAsPromised);
const expect = chai.expect;
const assert = chai.assert;

describe("integer square root computation", function() {
    this.timeout(100000);

    let circuit;

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "../IntSqrtOut/", "IntSqrtOut.circom"));
        await circuit.loadConstraints();
    });

    it("given 2 returns 4", async () => {

        let witness = await circuit.calculateWitness({
            "in": 4
        }, true);

        let out = witness[1];
        expect(Fr.eq(Fr.e(out), Fr.e(2))).to.be.true;
    });

    it("given 5 returns 2", async () => {
        let witness = await circuit.calculateWitness({
            "in": 5
        }, true);

        let out = witness[1];
        expect(Fr.eq(Fr.e(out), Fr.e(2))).to.be.true;
    });

    it("given 10 returns 3", async () => {
        let witness = await circuit.calculateWitness({
            "in": 10
        }, true);

        let out = witness[1];
        expect(Fr.eq(Fr.e(out), Fr.e(3))).to.be.true;
    });

    it("given 133333333333337 returns 11547005", async () => {
        let witness = await circuit.calculateWitness({
            "in": 133333333333337 
        }, true);

        let out = witness[1];
        expect(Fr.eq(Fr.e(out), Fr.e(11547005))).to.be.true;
    });

    it("given 15 does not return 4", async () => {
        let witness = await circuit.calculateWitness({
            "in": 15
        }, true);
    
        let out = witness[1];
        // Output should NOT be 4 (sqrt(15) is 3.87, and should round down to 3.)
        expect(Fr.eq(Fr.e(out), Fr.e(4))).to.be.false;
    });
    
    it("Should fail for incorrect square roots", async () => {
        let expectedFail = false;
        try {
            await circuit.calculateWitness({"in": [5, 25]}, true); // Incorrect input where 5 is not the sqrt of 25
        } catch (e) {
            expectedFail = true; // Expect an error due to constraint failure
        }
        assert.isTrue(expectedFail, "Expected an error but none was thrown");
    });
});
