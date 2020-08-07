const { TezosToolkit } = require("@taquito/taquito");
const fs = require("fs");
const { InMemorySigner } = require("@taquito/signer");
const path = require("path");
const { execSync } = require("child_process");
const { b58cdecode, hex2buf, buf2hex } = require("@taquito/utils");
const { getCodec, CODEC } = require("@taquito/local-forging");

const addressDecoder = getCodec(CODEC.ADDRESS);

const PACK_PREFIX = "05";
const BYTES_PREFIX = "0a";
const ADDRESS_SIZE = "00000016";
const CHAIN_ID_SIZE = "00000004";
const ARGS_SIZE = "00000020";

const { network: provider } = JSON.parse(
  fs.readFileSync("./deploy/Token.json").toString()
);

exports.getLigo = (isDockerizedLigo) => {
  let path = "ligo";
  if (isDockerizedLigo) {
    path = "docker run -v $PWD:$PWD --rm -i ligolang/ligo:next";
    try {
      execSync(`${path}  --help`);
    } catch (err) {
      console.log("Trying to use global version...");
      path = "ligo";
      execSync(`${path}  --help`);
    }
  } else {
    try {
      execSync(`${path}  --help`);
    } catch (err) {
      console.log("Trying to use Dockerized version...");
      path = "docker run -v $PWD:$PWD --rm -i ligolang/ligo:next";
      execSync(`${path}  --help`);
    }
  }
  return path;
};

exports.sleep = (ms) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

exports.setup = async (keyPath = "../fixtures/key") => {
  keyPath = path.join(__dirname, keyPath);
  const secretKey = fs.readFileSync(keyPath).toString();
  let tezos = new TezosToolkit();
  await tezos.setProvider({
    rpc: provider,
    signer: await new InMemorySigner.fromSecretKey(secretKey),
    config: {
      confirmationPollingTimeoutSecond: 1000,
    },
  });
  return tezos;
};

exports.concat = (a, b) => {
  var c = new a.constructor(a.length + b.length);
  c.set(a);
  c.set(b, a.length);

  return c;
};

exports.serializeAddress = (address) => {
  return hex2buf(
    PACK_PREFIX + BYTES_PREFIX + ADDRESS_SIZE + addressDecoder.encoder(address)
  );
};

exports.serializeChainId = (chainId) => {
  return hex2buf(
    PACK_PREFIX +
      BYTES_PREFIX +
      CHAIN_ID_SIZE +
      buf2hex(b58cdecode(chainId, new Uint8Array([87, 82, 0])))
  );
};
exports.serializeArgs = (args) => {
  return hex2buf(PACK_PREFIX + BYTES_PREFIX + ARGS_SIZE + buf2hex(args));
};
