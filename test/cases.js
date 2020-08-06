const { setup } = require("./utils");
const Token = require("./token").Token;
const Gsn = require("./gsn").Gsn;
const blake = require("blakejs");
const { b58cdecode, hex2buf, buf2hex } = require("@taquito/utils");
const { getCodec, CODEC } = require("@taquito/local-forging");

const assert = require("assert");

const addressDecoder = getCodec(CODEC.ADDRESS);

class Test {
  static async permit(gsnAddress, tokenAddress) {
    let AliceTezos = await setup();
    let BobTezos = await setup("../fixtures/key1");
    let gsn = await Gsn.init(AliceTezos, gsnAddress);

    const signerKey = await AliceTezos.signer.publicKey();
    const sender = await AliceTezos.signer.publicKeyHash();
    const receiver = await BobTezos.signer.publicKeyHash();
    const amount = 10;

    const argString =
      hex2buf(addressDecoder.encoder(sender)) +
      hex2buf(addressDecoder.encoder(receiver)) +
      Uint8Array.from([amount]);
    // console.log(argString);
    const argsHash = blake.blake2b(argString, null, 32);
    // console.log(argsHash);

    hex2buf(
      buf2hex(
        b58cdecode(
          await AliceTezos.rpc.getChainId(),
          new Uint8Array([87, 82, 0])
        )
      )
    );
    const paramsString =
      hex2buf(
        buf2hex(
          b58cdecode(
            await AliceTezos.rpc.getChainId(),
            new Uint8Array([87, 82, 0])
          )
        )
      ) +
      new Uint8Array([0]) +
      hex2buf(addressDecoder.encoder(tokenAddress)) +
      argsHash;
    // console.log(paramsString);
    const paramHash = blake.blake2b(paramsString, null, 32);
    // console.log(paramHash);
    const signature = AliceTezos.signer.sign(buf2hex(paramHash));
    // console.log(signature);

    operation = await gsn.permit(signerKey, signature, buf2hex(paramHash));
    await operation.confirmation();
    assert.equal(operation.status, "applied", "Operation was not applied");

    let finalStorage = await gsn.getFullStorage([paramHash]);
    assert.equal(finalStorage.storage[paramHash].signerKey, signerKey);
    assert.equal(finalStorage.storage[paramHash].paramHash, paramHash);
    assert.equal(finalStorage.storage[paramHash].signature, signature);
  }

  static async call(gsnAddress, tokenAddress) {}
}
exports.Test = Test;
