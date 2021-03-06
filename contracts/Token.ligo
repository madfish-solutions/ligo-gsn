#include "IToken.ligo"

(* Helper function to get account *)
function getAccount (const addr : address; const s : storage) : account is
  block {
    var acct : account :=
      record [
        balance    = 0n;
        counter    = 0n;
        allowances = (map [] : map (address, amt));
      ];
    case s.ledger[addr] of
      None -> skip
    | Some(instance) -> acct := instance
    end;
  } with acct

(* Helper function to get allowance for an account *)
function getAllowance (const ownerAccount : account; const spender : address; const s : storage) : amt is
  case ownerAccount.allowances[spender] of
    Some (amt) -> amt
  | None -> 0n
  end;

(* Transfer token to another account *)
function transfer (const from_ : address; const to_ : address; const value : amt; const sender_ : address; var s : storage) : return is
  block {
    (* Sending to yourself? *)
    if from_ = to_ then
      failwith("InvalidSelfToSelfTransfer")
    else skip;

    (* Retrieve sender account from storage *)
    const senderAccount : account = getAccount(from_, s);

    (* Balance check *)
    if senderAccount.balance < value then
      failwith("NotEnoughBalance")
    else skip;

    (* Check this address can spend the tokens *)
    if from_ =/= sender_ then block {
      const spenderAllowance : amt = getAllowance(senderAccount, sender_, s);

      if spenderAllowance < value then
        failwith("NotEnoughAllowance")
      else skip;

      (* Decrease any allowances *)
      senderAccount.allowances[sender_] := abs(spenderAllowance - value);
    } else skip;

    (* Update sender balance *)
    senderAccount.balance := abs(senderAccount.balance - value);

    (* Update storage *)
    s.ledger[from_] := senderAccount;

    (* Create or get destination account *)
    var destAccount : account := getAccount(to_, s);

    (* Update destination balance *)
    destAccount.balance := destAccount.balance + value;

    (* Update storage *)
    s.ledger[to_] := destAccount;
  } with ((nil : list(operation)), s)

function transferSigned (const from_ : address; const to_ : address; const value : amt; const signed: signature; const pk: key; const s : storage) : return is
  block { 
    var sender_ : address := Tezos.sender;
    if from_ = sender_ then skip else block {

      (* Retrieve sender account from storage *)
      const senderAccount : account = getAccount(from_, s);
      const counter : nat = senderAccount.counter;
  
      const params : bytes = Bytes.concat(Bytes.concat(bytes_pack(from_), bytes_pack(to_)), bytes_pack(value));
      var parametersHash : bytes := Crypto.blake2b(params);
  
      const unsignedTrx : bytes = Bytes.concat(Bytes.concat(bytes_pack(Tezos.chain_id), bytes_pack(counter)), Bytes.concat(bytes_pack(Tezos.self_address), bytes_pack(parametersHash)));
      parametersHash := Crypto.blake2b(unsignedTrx);
      const pkAddress : address = address(implicit_account(Crypto.hash_key(pk)));
      if Crypto.check(pk, signed, parametersHash) then sender_ := pkAddress else failwith("InvalidSignature");
      
      (* Update storage *)
      senderAccount.counter := counter + 1n;
      s.ledger[from_] := senderAccount;
    };
  } with transfer (from_, to_, value, sender_, s)

(* Approve an amt to be spent by another address in the name of the sender *)
function approve (const spender : address; const value : amt; var s : storage) : return is
  block {
    if spender = Tezos.sender then
      failwith("InvalidSelfToSelfApproval")
    else skip;

    (* Create or get sender account *)
    var senderAccount : account := getAccount(Tezos.sender, s);

    (* Get current spender allowance *)
    const spenderAllowance : amt = getAllowance(senderAccount, spender, s);

    (* Prevent a corresponding attack vector *)
    // if spenderAllowance > 0n and value > 0n then
    //   failwith("UnsafeAllowanceChange")
    // else skip;

    (* Set spender allowance *)
    senderAccount.allowances[spender] := value;

    (* Update storage *)
    s.ledger[Tezos.sender] := senderAccount;

  } with (noOperations, s)

(* View function that forwards the balance of source to a contract *)
function getBalance (const owner : address; const contr : contract(amt); var s : storage) : return is
  block {
    const ownerAccount : account = getAccount(owner, s);
  } with (list [transaction(ownerAccount.balance, 0tz, contr)], s)

(* View function that forwards the allowance amt of spender in the name of tokenOwner to a contract *)
function getAllowance (const owner : address; const spender : address; const contr : contract(amt); var s : storage) : return is
  block {
    const ownerAccount : account = getAccount(owner, s);
    const spenderAllowance : amt = getAllowance(ownerAccount, spender, s);
  } with (list [transaction(spenderAllowance, 0tz, contr)], s)

(* View function that forwards the totalSupply to a contract *)
function getTotalSupply (const contr : contract(amt); var s : storage) : return is
  block {
    skip
  } with (list [transaction(s.totalSupply, 0tz, contr)], s)

(* Main entrypoint *)
function main (const action : tokenAction; var s : storage) : return is
  block {
    skip
  } with case action of
    | Transfer(params) -> transfer(params.0, params.1.0, params.1.1, Tezos.sender, s)
    | TransferSigned(params) -> transferSigned(params.from_, params.to_, params.value, params.signed, params.pk, s)
    | Approve(params) -> approve(params.0, params.1, s)
    | GetBalance(params) -> getBalance(params.0, params.1, s)
    | GetAllowance(params) -> getAllowance(params.0.0, params.0.1, params.1, s)
    | GetTotalSupply(params) -> getTotalSupply(params.1, s)
  end;
