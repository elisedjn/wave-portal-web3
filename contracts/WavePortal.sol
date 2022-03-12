// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4; // verion of solidity compiler I wanna use (same as in hardhat.config.js)

import "hardhat/console.sol"; // allow console.log inside smart contract

contract WavePortal {
    uint256 totalWaves; // state variable automatically initialized to 0 and stored permanently in contract storage
    address[] wavers;

    uint256 private seed; // used to generate a random number

    /* Event is an inheritable member of a contract. An event is emitted, it stores the arguments passed in transaction logs. These logs are stored on blockchain and are accessible using address of the contract till the contract is present on the blockchain. An event generated is not accessible from within contracts, not even the one which have created and emitted them. */
    event NewWave(address indexed from, uint256 timestamp, string message);
    event NewWinner(address indexed winner);

    // Struct is a custom datatype
    struct Wave {
        address waver; // address of the user who waved
        string message; // message sent by the user
        uint256 timestamp; // timestamp when the user waved
    }

    // Declare the variable waves which is an array of Wave struct
    Wave[] waves;

    // adddress => uint mapping which associate an address with a number. Store the adddress with the last time user waved at us
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        //payable means we allow the contract to pay people
        // Will run when we initialize the contract for the first time
        console.log("Hey! I'm a contract and I'm smart!");
        //Set the initial seed thanks to info about the block
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        // public means it is available to be called on the blockchain

        // Make sure the last message from this user was at least 15 minutes ago
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Mahatma Gandhi said : 'To lose patience is to lose the battle'... Please wait 15 min before to send another piece of Peace."
        );
        //Update the current timestampe we have for this user
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        wavers.push(msg.sender);
        console.log("%s waved w/ message %s", msg.sender, _message); // msg.sender is the wallet address of the person who called the function
        waves.push(Wave(msg.sender, _message, block.timestamp)); // Store the wave data into the array

        //Generate a new seed for the nex user that sends a wave
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        // Give 20% chance that the user wins the prize
        if (seed <= 20) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether; //set up the prize amount in ether
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            ); // Check the condition (first argument), if false quit the function and cancel the transaction. address(this).balance is the contract balance.
            (bool success, ) = (msg.sender).call{value: prizeAmount}(""); // Here we send the money /!\ synthax is a bit weird
            require(success, "Failed to withdraw money from contract.");
            emit NewWinner(msg.sender);
        }

        //Emit the event
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    // function that returns the waves array
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }

    function getAddresses() public view returns (address[] memory) {
        return wavers;
    }
}
