const { setup } = require("./utils");
const Token = require("./token").Token;
const Gsn = require("./gsn").Gsn;

const assert = require("assert");

class Test {
  static async permit(gsnAddress) {
    let AliceTezos = await setup();
    let gsn = await Gsn.init(AliceTezos, gsnAddress);
    // signerKey
    // signature
    // paramHash
    const signerKey = await AliceTezos.signer.publicKey();
    const paramHash = "";
    const signature = "";

    let finalStorage = await gsn.getFullStorage([paramHash]);
    assert.equal(finalStorage.storage[paramHash].signerKey, signerKey);
    assert.equal(finalStorage.storage[paramHash].paramHash, paramHash);
    assert.equal(finalStorage.storage[paramHash].signature, signature);
  }

  static async call(gsnAddress, tokenAddress) {}
}
exports.Test = Test;
