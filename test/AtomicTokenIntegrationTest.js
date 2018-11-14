let AtomicToken = artifacts.require('./token/AtomicToken.sol');
let RegulatorService = artifacts.require('./token/RegulatorService.sol');
let RegulatorServiceCanTransfer = artifacts.require('./token/RegulatorServiceCanTransfer.sol');

contract('AtomicTokenIntegrationTest', accounts => {
  let atomicToken, regulatorService, regulatorServiceCanTransfer;
  let owner = accounts[0];
  let account1 = accounts[1];
  let account2 = accounts[2];
  let tryCatch = require('./exceptions.js').tryCatch;
  let errTypes = require('./exceptions.js').errTypes;

  let amounts = [
    web3.utils.toWei('0', 'ether'),
    web3.utils.toWei('999999.999', 'ether'), 
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether'),
    web3.utils.toWei('999999.999', 'ether')
    ];

  before('setup contracts for the suite', async () => {
    regulatorService = await RegulatorService.new({from: owner});
    regulatorServiceCanTransfer = await RegulatorServiceCanTransfer.new({from: owner});
    atomicToken = await AtomicToken.new(regulatorService.address, accounts, amounts, {from: owner});
  });

  it('Has a regulator service defined', async () => {
    assert.equal(await atomicToken.regulator(), regulatorService.address);
  });

  it('Returns valid lockup message', async () => {
      assert.notEqual(await atomicToken.verifyTransfer(owner, account1, 1000, {from: owner}), await atomicToken.SUCCESS_CODE());
  });

  it('Reverted a transfer request', async () => {
    await tryCatch(
      atomicToken.transfer(owner, 1000, {from: account1}),
      errTypes.revert
    );
  });

  it('Reverted an otherwise valid transferFrom request', async () => {
    await atomicToken.approve(owner, 1000, {from: account1});
    await tryCatch(
      atomicToken.transferFrom.call(account1, owner, 1000, {from: owner}),
      errTypes.revert
    );
  });
  
  it('Allowed a forcedTransfer request');
  // it('Allowed a forcedTransfer request', async () => {
  //   assert.equal(await atomicToken.forcedTransfer.call(account1, 1000, {from: owner}), true);
  // });

  it('Reverted a request to replace the service from a regular user', async () => {
    await tryCatch(
        atomicToken.replaceRegulator.call(regulatorServiceCanTransfer.address, {from: account1}),
        errTypes.revert
    );
  });

  it('Replaced the regulator service', async () => {
    await atomicToken.replaceRegulator(regulatorServiceCanTransfer.address, {from: owner});
    assert.equal(await atomicToken.regulator(), regulatorServiceCanTransfer.address);
  });

  it('Reverted a request to change ownership from non owner', async () => {
    await tryCatch(
        atomicToken.transferOwnership(account1, {from: account1}),
        errTypes.revert
      ) 
  });

  it('Allowed a transfer using a new regulator service', async () => {
    assert.equal(await atomicToken.transfer.call(owner, 1000, {from: account1}), true);
  });

  it('Allowed a transferFrom using a new regulator service', async () => {
      await atomicToken.approve(owner, 1000, {from: account1})
      assert.equal(await atomicToken.transferFrom.call(account1, owner, 1000, {from: owner}), true);
    });

    // it('Allowed the owner to mint tokens', async () => {
    //   let totalSupply = await atomicToken.totalSupply();
    //   await atomicToken.mint(owner, 1000);
    //   assert.equal(await atomicToken.balanceOf(owner), 1000);
    // });

    // it('Allowed the owner to burn a users tokens', async () => {
    //   let totalSupply = await atomicToken.totalSupply();
    //   await atomicToken.burn(owner, 500);
    //   assert.equal(await atomicToken.balanceOf(owner), 500);
    //   assert.equal(await atomicToken.totalSupply(), (totalSupply - 500));
    // });

  it('Replaced the owner', async () => {
    await atomicToken.transferOwnership(account1);
    assert.equal(await atomicToken.owner(), account1);
  });
  
});
