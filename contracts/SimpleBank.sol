/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SimpleBank {
    
    //
    // State variables
    //
    
    /* Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) private balances;
    
    /* Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner;
    
    //
    // Events - publicize actions to external listeners
    //
    
    /* Add an argument for this event, an accountAddress */
    event LogEnrolled(address accountAddress);

    /* Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(address accountAddress, uint amount);

    /* Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);


    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    constructor() public {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() external payable {
        revert('Fallback Function invoked, but cannot send payment directly to contract.');
    }

    /// @notice Get balance
    /// @return The balance of the user
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function getBalance() public view isEnrolled returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool) {
        enrolled[msg.sender] = true; // Calling Enroll when enrolled is OK
        emit LogEnrolled(msg.sender);
        return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event
    // Users should be enrolled before they can make deposits
    function deposit() public payable isEnrolled returns (uint) {
        require(msg.value > 0, 'Must deposit a non-zero amount.');
        balances[msg.sender] = safeAdd(balances[msg.sender],msg.value);
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint withdrawAmount) public isEnrolled returns (uint) {
        require(withdrawAmount > 0, 'Must withdraw a non-zero amount.');
        require(withdrawAmount <= balances[msg.sender], 'Insufficient funds.');
        balances[msg.sender] = safeSubtract(balances[msg.sender],withdrawAmount);
        msg.sender.transfer(withdrawAmount);
        emit LogWithdrawal(msg.sender,withdrawAmount,balances[msg.sender]);
        return balances[msg.sender];
    }

    // Modifier to check that the calling account is enrolled.
    modifier isEnrolled() {
        require(enrolled[msg.sender],'Caller is not enrolled.');
        _;
    }

    // Source: Copied from Zepplin SafeMath library
    // would like to actually use properly, but solc incompatibilities.
    function safeAdd(uint a, uint b) private pure returns (uint) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    // Source: Copied from Zepplin SafeMath library
    function safeSubtract(uint256 a, uint256 b) private pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
}
