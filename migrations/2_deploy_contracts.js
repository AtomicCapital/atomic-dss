var RegulatorService = artifacts.require('./contracts/RegulatorService');
var RegulatorServiceCanTransfer = artifacts.require('./contracts/RegulatorServiceCanTransfer');
var AtomicToken = artifacts.require('./contracts/AtomicToken');

module.exports = function(deployer) {
  deployer.deploy(RegulatorServiceCanTransfer);
  deployer.deploy(RegulatorService).then(() => {
    return deployer
      .deploy(AtomicToken, RegulatorService.address, [], [])
      .catch(function(err) {
        console.log(err);
      });
  });
};