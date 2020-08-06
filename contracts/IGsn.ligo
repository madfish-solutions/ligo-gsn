#include "IToken.ligo"

type parameterType is record [
  params: transferParams;
  counter: nat;
  contractAddress: address;
];

type permitParameter is record [
  signerKey: key;
  signature: signature;
  paramHash: bytes;
];

type permitsType is big_map(bytes, permitParameter)
type storage is permitsType

type action is
| Permit of permitParameter 
| Call of parameterType

