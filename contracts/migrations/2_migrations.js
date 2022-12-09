const epicgame = artifacts.require("epicgame");

module.exports = function (deployer) {
  deployer.deploy(epicgame);
};
