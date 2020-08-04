type permitsType is big_map(bytes, address)
type storageType is nat
type parameterType is nat

type storage is record [
  presignedParams: permitsType;
  counter: nat;
  wrappedStorage: storageType;
];

type sentParameter is record [
  approvalMap: permitsType;
  packedParam: bytes;
  permitter: address;
];
type permitParameter is record [
  signerKey: key;
  signature: signature;
  paramHash: bytes;
];

type revokeParameter is record [
  user: address;
  paramHash: bytes;
];

type wrappedParameter is parameterType

type action is
| Permit of permitParameter 
// | Revoke of revokeParameter
| Wrapped of wrappedParameter

