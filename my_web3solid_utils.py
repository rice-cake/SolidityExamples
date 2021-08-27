
# Author: rice-cake
# Date: 26-Aug-2021

import os
import json
from web3 import Web3

#################################################################################################
# Accounts, Fees

def accounts_stats(web3_conn):       
    latest_block_number = web3_conn.eth.getBlock('latest').number
    print("Latest block number:", latest_block_number) 
    sum_balances, total_transactions = 0, 0
    for acc in web3_conn.eth.accounts:
        b = web3_conn.eth.getBalance(acc)
        sum_balances += b
        t = web3_conn.eth.getTransactionCount(acc)
        total_transactions += t
        print(acc, web3_conn.fromWei(b, 'Ether'), t)    
    # print('{:.2E}'.format(sum_balances)) f'{sum_balances:.2E}' # rounds?
    print("\nSum of balances:", sum_balances, 'wei  ', web3_conn.fromWei(sum_balances, 'Ether'), 'ETH')
    print("Total transactions:", total_transactions)
    return (sum_balances, latest_block_number)


# fee for all the transactions in this session
def total_fees(web3_conn, start_bn, end_bn):  
    latest_block = web3_conn.eth.getBlock('latest')
    print("Latest block number:", latest_block.number)
    print("Gas price:", web3_conn.eth.gas_price, 'wei') # default in ganache    
    total_fees = 0 # wei
    for i in range(start_bn, end_bn+1):  # inclusive range of block numbers
        b = web3_conn.eth.getBlock(i)
        t = web3_conn.eth.getTransactionByBlock(b.hash, 0) 
        # multiplying with constant here but in general, gasPrice can vary
        total_fees += (b.gasUsed * t.gasPrice) # t.gas is block gas limit, t.gas > b.gasUsed
        assert t.gas > b.gasUsed
        print(b.number, b.gasUsed, t.nonce, t.blockNumber, t.gas, t.gasPrice)    
    print("\nTotal session fees:", total_fees, 'wei ', total_fees/(10**18), 'ETH')
    return total_fees


#################################################################################################
# Contract

# prep contract for deployment via web3_conn, specify contract construction values in **kwargs
def prep_contract(web3_conn, contract_dir, contract_name, **kwargs):
    # obtain contract ABI
    abi_filename = os.path.join(contract_dir, contract_name + ".abi")
    with open(abi_filename) as ifn:
        contract_abi = json.load(ifn)
    # obtain contract binary in hex (bytecode?)
    bin_filename = os.path.join(contract_dir, contract_name + ".bin")
    with open(bin_filename) as ifn:
        contract_bin = ifn.read()
    the_contract = web3_conn.eth.contract(abi=contract_abi, bytecode=contract_bin)
    est_gas = the_contract.constructor(**kwargs).estimateGas()
    print("Estimated gas used to construct/deploy contract:", est_gas)
    contract_sz = len(the_contract.bytecode.hex())
    print("Contract size:", contract_sz, "hexbytes")
    print("Estimated gas used per hexbyte:", est_gas/contract_sz)
    return (the_contract, est_gas)


# deploy contract to blockchain and retrieve deployed contract for calling
def deploy_contract(web3_conn, account, the_contract, **kwargs):
    tx_hash = the_contract.constructor(**kwargs).transact({"from": account})
    tx_receipt = web3_conn.eth.waitForTransactionReceipt(tx_hash)    
    the_dcontract = web3_conn.eth.contract(abi=the_contract.abi, 
                                        address=tx_receipt.contractAddress)
    print("Contract deployed at:", the_dcontract.address)
    print("Gas used to construct/deploy contract:", tx_receipt.gasUsed)
    return (the_dcontract, tx_receipt.gasUsed)


#################################################################################################

