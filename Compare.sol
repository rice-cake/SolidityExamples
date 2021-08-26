// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.16 < 0.9.0;

// https://docs.soliditylang.org/en/v0.8.7/contracts.html

contract Compare {	
	
	// private only prevents other contracts (within the blockchain) from getting & setting a variable, 
	// the variable is essentially still visible to everyone outside the blockchain
	
	// immutable makes the variable constant once it is assigned at construction
	// use constant if assigning at compile-time
	
	address private immutable owner;	
	
	// public variables become part of the contract interface
	// automatic getter function (contract_name()) is generated for public state variables	
	
	string public contract_name;  

	string public message;
	event Message(address from, string msg);	// how to listen for these events in Python?

	// the constructor is called constructor!
	constructor(string memory init_name) {
		owner = msg.sender;
		contract_name = init_name;
	}

	// string is a dynamic type, specify storage as memory
	// https://docs.soliditylang.org/en/v0.8.7/types.html#data-location-assignment
	// contract name can only be changed by contract owner
	function change_contract_name(string memory new_name) public {
		if (msg.sender == owner) {
			contract_name = new_name;
			message = "Contract name changed";			
		}
		else
			message = "Contract name not changed";		
		emit Message(msg.sender, message);
	}

	//these functions are all non-payable, and do not mutate state (pure)
	
	// example of a "helper" function
	// internal functions can only be called from within the contract that defined it, or its children contracts
	// use of arrays https://docs.soliditylang.org/en/v0.8.7/types.html	
	function _greaterArray(int[] memory array_1, int[] memory array_2) internal pure 
			returns(bool[] memory answers, uint total_true) {
		uint sz = array_1.length;
		require(sz == array_2.length, "Arrays must be of the same length");
		uint sum = 0;
		bool[] memory results = new bool[](sz);	
		for (uint i=0; i < sz; ++i) {
			bool b = array_1[i] > array_2[i];
			results[i] = b;
			if (b) ++sum;
		}
		return (results, sum);
	}
	
	// arguments passed by reference (memory to memory)?
	// returns true if all answers are true
	function greaterArray(int[] memory array_1, int[] memory array_2) public pure returns(bool answer) {		
		// var (answers, total_true) = _greaterArray(array_1, array_2);  // var deprecated 
		//https://ethereum.stackexchange.com/questions/45559/
		
		bool[] memory answers; uint total_true;
		(answers, total_true) = _greaterArray(array_1, array_2);
		return answers.length == total_true;		
	}
}
