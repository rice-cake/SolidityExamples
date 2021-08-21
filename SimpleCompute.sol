// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.16 < 0.9.0;

contract Compare {	
	
	//these functions are all non-payable, and do not mutate state (pure)

	function greater(uint value_1, uint value_2) public pure returns(bool answer) {
		bool result = value_1 > value_2;		
		return result;
	}

	function equal(uint value_1, uint value_2) public pure returns(bool answer) {
		bool result = value_1 == value_2;		
		return result;
	}
}


contract Arithmetic {
	uint value_1;

	//using default constructor, what's the initial value of value_1?

	function getState() public view returns(uint cstate) {
		return value_1;
	}

	//these functions are all non-payable, and mutate state

	function add(uint value_2) public returns(uint answer) {
		 value_1 += value_2;	// check for nothing to do value_2 == 0?
		 return value_1;
	}		

	function subtract(uint value_2) public returns(uint answer) {
		 value_1 -= value_2;  	// not checking if value_1 can become negative!
		 return value_1;
	}

	function multiply(uint value_2) public returns(uint answer) {
		 value_1 *= value_2;  	// not checking for overflow!
		 return value_2;
	}

	function divide(uint value_2) public returns(uint answer) {
		 value_1 /= value_2; 	// not checking for divide by zero!
		 return value_1;
	}
}
