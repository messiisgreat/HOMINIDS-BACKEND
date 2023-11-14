#!/bin/bash

echo "Select an action:"
echo "1. Check balances"
echo "2. Compile"
echo "3. Deploy"
echo "4. Flatten contract"
echo "5. Mint script"
echo "6. Interact task"
echo "7. CCTX"
echo "8. Run tests"
echo "9. Exit"

read choice

case $choice in
  1)
    echo "Fetching balances"
    npx hardhat balances
    ;;
  2)
    echo "Compiling contracts..."
    npx hardhat compile --force
    ;;
  3)
    echo "Executing deploy script"
    echo "Script path: scripts/deploy.ts"
    npx hardhat run scripts/deploy.ts --network zeta_testnet
    ;;
  4)
    echo "Select a contract to flatten:"
    echo "1. USDCToken.sol"
    echo "2. ERA.sol"
    echo "3. OmnichainERA.sol"
    echo "4. MinftNFt.sol"
    read contract_choice

    case $contract_choice in
      1)
        contract_filename="USDCToken.sol"
        output_filename="USD.txt"
        ;;
      2)
        contract_filename="ERA.sol"
        output_filename="ERA.txt"
        ;;
      3)
        contract_filename="OmnichainERA.sol"
        output_filename="OmnichainERA.txt"
        ;;
      4)
        contract_filename="MinftNFt.sol"
        output_filename="MinftNFt.txt"
        ;;
      *)
        echo "Invalid contract choice"
        exit 1
        ;;
    esac

    echo "Flattening contract $contract_filename to $output_filename"
    npx hardhat flatten contracts/"$contract_filename" > Verify/"$output_filename"
    ;;
  5)
    echo "Executing mint script"
    echo "Script path: scripts/mintNftApproveTokens.ts"
    npx hardhat run scripts/mintNftApproveTokens.ts --network zeta_testnet
    ;;
  6)
    echo "Enter the value for --select option:"
    read select_option
    echo "Executing 'npx hardhat interact --network mumbai_testnet --select $select_option'"
    npx hardhat interact --network mumbai_testnet --select "$select_option"
    ;;
  7)
    echo "Enter the transaction hash:"
    read tx_hash
    echo "Executing CCTX with transaction hash: $tx_hash"
    npx hardhat cctx --tx "$tx_hash"
    ;;
  8)
    echo "Running tests"
    npx hardhat test
    ;;
  9)
    echo "Exiting script"
    exit 0
    ;;
  *)
    echo "Invalid choice: $choice"
    ;;
esac
