const UserTasks = artifacts.require("UserTasks");

module.exports = function (deployer) {
  deployer.deploy(UserTasks);
};
