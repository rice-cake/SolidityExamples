// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.16 < 0.9.0;

// https://docs.soliditylang.org/en/v0.8.7/contracts.html#function-modifiers

// https://ethereum.stackexchange.com/questions/29608/whats-the-order-of-execution-for-multiple-function-modifiers

// specifies modifiers for "safe" arithmetic operations
contract Weird {

	modifier non_zero(uint val) {
		require (val != 0, "Non-zero value required");
		_; 	
	}	

	// specify some upper and lower limits for demo
	
	// require does not get applied after code in this execution, but in the next call!
	modifier upper_limit(uint val) {
		_;	// code using this modifier gets inserted here
		require (val <= 10000, "Value outside range"); 	// throws ContractLogicError, reverts trans
	}

	// same problem as upper_limit, modifier is actually a pre-condition for the next call of this operation	
	modifier lower_limit(int val, int min) {
		_;	// code using this modifier gets inserted here
		require (val > min, "Remainder value outside range");		
	}
}


contract Arithmetic is Weird {
	uint public value_1;	

	//these functions are all non-payable, and mutate state

	function reset() public {
		value_1 = 0;
	}

	// revert trans if value_2 is 0, nothing to do - save gas?
	// modifier upper_limit does NOT work as expected, code inserted before require
	// value_1 is only checked on the next operation	
	function add(uint value_2) public non_zero(value_2) upper_limit(value_1) {
		value_1 = value_1 + value_2;		
	}		

	// require works
	function multiply(uint value_2) public upper_limit(value_1) {
		value_1 *= value_2;
		// safer to do checks this way, unless a modifier relates to multiple functions (repetition integrity loss)
		// require (value_1 <= 10000, "Value outside range"); 
	}

	function subtract(uint value_2) public {
		value_1 -= value_2;		 
	}

	// modifier works, code inserted after require
	function divide(uint value_2) public non_zero(value_2) {		 		 
		value_1 /= value_2; 
	}
	
	error RemainderValueOutOfRange(string msg, int val);	//how to convert u/int to string?
	// remainder must be > min_remainder, just an example of a function with multiple modifiers
	// when min_remainder = -1, function is essentially same as divide
	int remainder;  // have to declare outside function else Compile error: remainder is undeclared identifier
					// but min_remainder is ok
	function messy_divide(uint value_2, int min_remainder) public non_zero(value_2) {
															// lower_limit(remainder, min_remainder) {
		
		// without casting to int, Compile error uint256 - int256 incompatible, 
		// casting uint256 x to int256 x is safe so long as x is less than (<) type(uint).max/2 = 2**255 
		// here value_1 max is 10000 (?)
		
		remainder = int(value_1 % value_2);  // int (uint % uint)
		value_1  = uint(int(value_1) - remainder) / value_2;  	//quotient
		if (remainder <= min_remainder)			
			revert RemainderValueOutOfRange({msg: "Remainder value", val: remainder});	 //need dict?
	}

	// https://ethereum.stackexchange.com/questions/6947/math-operation-between-int-and-uint#6950
}
