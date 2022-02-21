const KyberSwap = artifacts.require("KyberSwap");
const ChrisToken = artifacts.require("ChrisToken");

contract("KyberSwap", (accounts) => {
    it("Should deploy the smart contract properly", async () => {
        // Deploy the token
        // Deploy the smart contract
        // Send the token to the smart contract
        

        // Contract's balances
        // token.balanceOf(kyberSwapInstance.address); => token balance
        // web3.eth.getBalance(kyberSwapInstance.address); => Eth balance

        // Trade account's balances
        // token.balanceOf(accounts[0]); => token balance
        // web3.eth.getBalance(accounts[0]); => Eth balance

        // Swap Eth for the token
        

        // Approve the smart contract to use your token before trade
    

        // Swap the token for Eth
        // 

        const kyberSwapInstance = await KyberSwap.deployed();
        const chrisTokenInstance = await ChrisToken.deployed();

        // State check tests
        assert(kyberSwapInstance.address !== "");

        const token = await kyberSwapInstance.token();
        assert(token === chrisTokenInstance.address);

        // Function check tests
        const rate = await kyberSwapInstance.ethToERC20Rate();
        assert(rate.toNumber() === 10000);

        await kyberSwapInstance.setEthToERC20Rate(2000);
        const newRate = await kyberSwapInstance.getEthToERC20Rate();
        assert(newRate.toNumber() === 2000);

        // Trade check test
        const tokenTransferAmt = web3.utils.toBN("1000000000000000000000000");
        await chrisTokenInstance.transfer(kyberSwapInstance.address, tokenTransferAmt.toString(), {from: accounts[0]});
        let contractTokenBal = web3.utils.toBN(await chrisTokenInstance.balanceOf(kyberSwapInstance.address));
        assert(contractTokenBal.eq(tokenTransferAmt));

        const ethAmt = web3.utils.toBN("4000000000000000000");
        await kyberSwapInstance.swapEthForERC20(accounts[0], {value: ethAmt.toString()});
        setTimeout(() => {
        }, 10000);
        let contractEthBal = web3.utils.toBN(await web3.eth.getBalance(kyberSwapInstance.address));
        
        assert(ethAmt.eq(contractEthBal));

        const tokenAmt = web3.utils.toBN("4000000000000000000000");
        await chrisTokenInstance.approve(kyberSwapInstance.address, tokenAmt.toString(), {from: accounts[0]});
        setTimeout(() => {
        }, 10000);
        await kyberSwapInstance.swapERC20ForEth(accounts[0], tokenAmt.toString());
        setTimeout(() => {
        }, 10000);
        contractEthBal = web3.utils.toBN(await web3.eth.getBalance(kyberSwapInstance.address));
        assert(contractEthBal.eq(ethAmt.div(web3.utils.toBN(2))));
    });
});