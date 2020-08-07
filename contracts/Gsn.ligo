#include "IGsn.ligo"

type transfer_type is TransferType of transferSignedParams

function getTokenContract(const tokenAddress : address) : contract(transfer_type) is 
    case (Tezos.get_entrypoint_opt("%transferSigned", tokenAddress) : option(contract(transfer_type))) of 
      Some(contr) -> contr
      | None -> (failwith("01"):contract(transfer_type))
    end;

function permit (const params: permitParameter; const s : storage) : storage is
block {  
  case s[params.paramHash] of 
    | Some(p) -> failwith("PermitExists")
    | None -> skip
    end;

  if Crypto.check(params.signerKey, params.signature, params.paramHash) then {
    s[params.paramHash] := params;
  } else failwith("InvalidSignature");
 } with s

function call (const args: parameterType; const s : storage) : (list(operation) * storage) is
block {  
  const counter : nat = args.counter;
  const parameters : transferParams = args.params;
  const contractAddress : address = args.contractAddress;
  var operations : list(operation) := nil;

  const params : bytes = Bytes.concat(Bytes.concat(bytes_pack(parameters.0), bytes_pack(parameters.1.0)), bytes_pack(parameters.1.1));
  var parametersHash : bytes := Crypto.blake2b(params);
  const unsignedTrx : bytes = Bytes.concat(Bytes.concat(bytes_pack(Tezos.chain_id), bytes_pack(counter)), Bytes.concat(bytes_pack(contractAddress), bytes_pack(parametersHash)));
  parametersHash := Crypto.blake2b(unsignedTrx);
  case s[parametersHash] of 
    | Some(p) -> {      
      remove unsignedTrx from map s;
      operations := transaction(
        TransferType(record[
          from_ = parameters.0;
          to_ = parameters.1.0;
          value = parameters.1.1;
          signed = p.signature;
          pk = p.signerKey;
        ]), 
        0mutez, 
        getTokenContract(contractAddress)
      )
      # operations; 
    }
    | None -> failwith("Invalid_Hash")
    end;
 } with (operations, s)

function main (const p : action ; const s : storage) :
  (list(operation) * storage) is case p of
    | Permit(args) -> ((nil : list(operation)), permit(args, s)) 
    | Call(args) -> call(args, s) 
  end
