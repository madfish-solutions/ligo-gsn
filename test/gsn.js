class Gsn {
  constructor(Tezos, contract) {
    this.tezos = Tezos;
    this.contract = contract;
  }

  static async init(Tezos, tokenAddress) {
    return new Gsn(Tezos, await Tezos.contract.at(tokenAddress));
  }

  async getFullStorage(keys = []) {
    const storage = await this.contract.storage();
    var result = {
      ...storage,
    };
    result = await keys.reduce(async (prev, current) => {
      let entry;

      try {
        entry = await storage.get(current);
      } catch (ex) {
        console.error(ex);
      }

      return {
        ...(await prev),
        [current]: entry,
      };
    }, Promise.resolve({}));

    return result;
  }

  async permit(signerKey, signature, paramHash) {
    let operation = await this.contract.methods
      .permit(paramHash, signature, signerKey)
      .send();
    await operation.confirmation();
    return operation;
  }
}
exports.Gsn = Gsn;
