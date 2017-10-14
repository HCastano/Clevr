var ConvertLib = artifacts.require("./ConvertLib.sol");
var ClevrPosts = artifacts.require("./ClevrPosts.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(ClevrPosts);
  // deployer.deploy(ConvertLib);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);
};
