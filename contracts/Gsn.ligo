#include "IGsn.ligo"

function main (const p : action ; const s : storage) :
  (list(operation) * storage) is case p of
      | Permit(args) -> ((nil : list(operation)), s) 
      // | Revoke(args) -> ((nil : list(operation)), s) 
      | Wrapped(args) -> ((nil : list(operation)), s) 
    end
