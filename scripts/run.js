//hre = HardHat Runtime Environment, imported automatically when running npx hardhat, built using hardhat.config.js

const main = async () => {
  const [owner, randomPerson1, randomPerson2] = await hre.ethers.getSigners(); //grab wallet address of contract owner and a random wallet
  const waveContractFactory = await hre.ethers.getContractFactory('WavePortal'); //compile the contract, generate the necessary files under artifacts directory
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther('0.1')
  }); //Hardhat create a local Ethereum network for this contract - Will be destroyed after the script completes
  // The contract is deployed with 0.1 ether from my wallet, this 0.1 ether become the contract fund.
  await waveContract.deployed(); // wait that the contract is deployed, constructor will run here
  console.log('Contract deployed to:', waveContract.address); //address of the contract in the blockchain
  console.log('Contract deployed by:', owner.address);

  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  ); // function from hre.ethers that give the balance

  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)
  ); // format the ethers to see the balance

  // Call manually the functions : get nb of waves => wave => get the new nb of waves
  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log(waveCount.toNumber());

  let waveTxn = await waveContract.wave('I love you!');
  await waveTxn.wait();

  waveTxn = await waveContract.connect(randomPerson1).wave('You are beautiful'); //use a random person to wave at us
  await waveTxn.wait();

  // waveTxn = await waveContract.connect(randomPerson2).wave('Just breathe...'); //use a random person to wave at us
  // await waveTxn.wait();

  waveTxn = await waveContract
    .connect(randomPerson2)
    .wave('...Everything will be fine'); //use a random person to wave at us
  await waveTxn.wait();

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    'Contract balance:',
    hre.ethers.utils.formatEther(contractBalance)
  );

  waveCount = await waveContract.getTotalWaves();
  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
  let wavers = await waveContract.getAddresses();
  console.log('Wavers', wavers.join(', '));
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit Node process without error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
  // More info about Node exit status code : https://stackoverflow.com/a/47163396/7974948
};

runMain();
