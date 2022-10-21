const { expect } = require("chai");

describe("Dex", () => {
  it("should work", async () => {
    const [owner, otherAccount] = await ethers.getSigners();

    // deploy the test ERC20 tokens so we can actually register a new pool.
    const initialSupply = ethers.utils.parseUnits("100", 8);
    const UsdcToken = await ethers.getContractFactory("UsdcToken");
    const usdcToken = await UsdcToken.deploy(initialSupply);
    const GGToken = await ethers.getContractFactory("GGToken");
    const ggToken = await GGToken.deploy(initialSupply);

    const Dex = await ethers.getContractFactory("Dex");
    const dex = await Dex.deploy();

    await dex.registerPool(usdcToken.address, ggToken.address);

    // deposit some usdc.
    const depositAmount = ethers.utils.parseUnits("2", 8);
    await usdcToken.approve(dex.address, depositAmount);
    await dex.deposit("USDCGG", usdcToken.address, depositAmount);
    expect(
      await dex.poolTokenBalances(owner.address, usdcToken.address)
    ).to.equal(depositAmount);

    // deposit some ggToken.
    const ggTokenDepositAmount = ethers.utils.parseUnits("1", 8);
    await ggToken.approve(dex.address, ggTokenDepositAmount);
    await dex.deposit("USDCGG", ggToken.address, ggTokenDepositAmount);
    expect(
      await dex.poolTokenBalances(owner.address, ggToken.address)
    ).to.equal(ggTokenDepositAmount);

    console.log(
      "usdc balance before swap",
      await usdcToken.balanceOf(owner.address)
    );
    console.log(
      "gg token balance before swap",
      await ggToken.balanceOf(owner.address)
    );

    const amountUSDCToSwap = ethers.utils.parseUnits("0.5", 8);
    await usdcToken.approve(dex.address, amountUSDCToSwap);
    await dex.swap("USDCGG", usdcToken.address, amountUSDCToSwap);

    console.log(
      "usdc balance after swap",
      await usdcToken.balanceOf(owner.address)
    );
    console.log(
      "gg token balance after swap",
      await ggToken.balanceOf(owner.address)
    );

    // await dex.withdraw("USDCGG", usdcToken.address, depositAmount);
    // expect(
    //   await dex.poolTokenBalances(owner.address, usdcToken.address)
    // ).to.equal(0);

    // expect(await usdcToken.balanceOf(dex.address)).to.equal(0);
  });
});
