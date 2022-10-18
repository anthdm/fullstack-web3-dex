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
    const pool = await dex.pools("USDCGG");
    expect(pool.isOpen).to.equal(true);

    const depositAmount = ethers.utils.parseUnits("1", 8);
    await usdcToken.approve(dex.address, depositAmount);
    await dex.deposit("USDCGG", usdcToken.address, depositAmount);
    expect(
      await dex.poolTokenBalances(owner.address, usdcToken.address)
    ).to.equal(depositAmount);

    await dex.withdraw("USDCGG", usdcToken.address, depositAmount);
    expect(
      await dex.poolTokenBalances(owner.address, usdcToken.address)
    ).to.equal(0);

    expect(await usdcToken.balanceOf(dex.address)).to.equal(0);
  });
});
