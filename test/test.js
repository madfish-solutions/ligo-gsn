const fs = require("fs");

const { address: tokenAddress } = JSON.parse(
  fs.readFileSync("./deploy/Token.json").toString()
);

const { address: gsnAddress } = JSON.parse(
  fs.readFileSync("./deploy/Gsn.json").toString()
);

const { Test } = require("./cases");

describe("Correct calls", function () {
  describe("Permit()", function () {
    it("should store permit request", async function () {
      await Test.permit(gsnAddress, tokenAddress);
    });
  });

  describe("Call()", function () {
    it("should resend request to token", async function () {
      await Test.call(gsnAddress, tokenAddress);
    });
  });
});
