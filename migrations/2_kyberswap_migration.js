const KyberSwap = artifacts.require("KyberSwap");
const ChrisToken = artifacts.require("ChrisToken");

module.exports = function (deployer) {
    // const tokenAddress = "0x9bCa299b827E6eFc6f558e37C2f2C6856CbA2C43";
    const rate = 10000;
    deployer.deploy(ChrisToken).then(async () => {
        const tokenInstance = await ChrisToken.deployed();
        return deployer.deploy(KyberSwap, rate, tokenInstance.address);
    });
};
