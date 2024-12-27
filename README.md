# Clarity Health Data Marketplace Smart Contract

The Health Data Marketplace Smart Contract allows users to buy and sell health data securely on the Stacks blockchain. It offers a decentralized platform for data transactions, allowing users to set their data prices, handle commission fees, manage refunds, and control global data limits. With administrative controls, the contract owner can manage important parameters such as data price, commission rates, refund percentages, and system-wide data limits. This contract is designed to provide a secure, transparent, and efficient marketplace for health data.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Setup Instructions](#setup-instructions)
- [Contract Structure](#contract-structure)
  - [Constants](#constants)
  - [Data Variables](#data-variables)
  - [Private Functions](#private-functions)
  - [Public Functions](#public-functions)
- [Error Handling](#error-handling)
- [Security](#security)
- [Audit](#audit)
- [Contributing](#contributing)
- [Licensing](#licensing)

## Overview

The Health Data Marketplace Smart Contract enables users to trade health data in a peer-to-peer marketplace, with functionality for setting prices, managing commissions, handling refunds, and ensuring fair limits on the data stored in the system. The contract's owner has administrative capabilities to adjust the system-wide parameters. The contract utilizes the Stacks blockchain to enable transparent and tamper-proof transactions.

## Key Features

- **Data Price Management:** 
  - The contract owner can set the price of health data in microstacks (STX), allowing users to buy and sell data at varying rates.

- **Commission Fees:**
  - A commission fee is automatically applied to transactions. The contract owner can configure the commission percentage.

- **Refunds:**
  - In the event of an invalid transaction, users are entitled to a refund. The refund percentage can be customized by the contract owner.

- **Data Limit Management:**
  - A global data limit can be enforced to control the total amount of data in the system, ensuring optimal performance and storage management.

- **Marketplace Transactions:**
  - Users can add their data to the marketplace for sale, purchase data from others, or remove their data from the marketplace.

- **Balances and Funds Management:**
  - The contract maintains a balance of both data and STX for each user. Users can view and manage their balances and make transactions accordingly.

- **Admin Controls:**
  - The contract owner can adjust critical parameters such as data price, commission fees, refund percentages, and global data limits, ensuring the smooth functioning of the marketplace.

## Setup Instructions

To deploy and interact with this smart contract on the Stacks blockchain, follow the steps below:

### 1. Install Clarinet

Clarinet is the recommended development framework for deploying smart contracts on Stacks. To install Clarinet, follow the official installation guide:

- [Clarinet Installation Guide](https://www.clarinet.xyz/docs/)

### 2. Deploy the Contract

After setting up Clarinet, deploy the smart contract to your Stacks node using the following command:

```bash
clarinet deploy
```

### 3. Interact with the Contract

Once the contract is deployed, interact with it via the Clarinet CLI, calling public functions like setting the data price, adding data to the marketplace, or purchasing data.

Example of interacting with the contract:

```bash
clarinet call set-data-price --price 1000
clarinet call buy-data-from-user --data-id 1 --amount 500
```

## Contract Structure

### Constants

Constants define the error messages and roles within the contract:

- **`contract-owner`**: The address of the contract owner, who is authorized to perform administrative actions.
- **`err-owner-only`**: Error raised when a non-owner tries to call restricted functions.
- **`err-not-enough-data`**: Error when a user does not have enough data for a transaction.
- **`err-invalid-price`**: Error when an invalid data price is set.
- **`err-invalid-amount`**: Error when the data amount in a transaction is invalid.
- **`err-invalid-fee`**: Error when the commission fee is invalid.
- **`err-data-transfer-failed`**: Error when data transfer between users fails.
- **`err-limit-exceeded`**: Error raised when the global data limit is exceeded.

### Data Variables

- **`data-price`**: The price per unit of health data in microstacks (STX).
- **`max-data-per-user`**: The maximum amount of data a user can upload to the marketplace.
- **`commission-fee`**: The percentage of commission taken from each transaction.
- **`refund-percentage`**: The percentage refunded for invalid transactions.
- **`data-limit`**: The global data limit for the system.
- **`current-data`**: Tracks the current total amount of data stored in the system.

### Data Maps

- **`user-data-balance`**: Stores the data balance of each user.
- **`user-stx-balance`**: Stores the STX balance of each user.
- **`data-for-sale`**: Maps data listings to their respective price and owner.

### Private Functions

- **`calculate-commission`**: Computes the commission fee for a given transaction amount.
- **`calculate-refund`**: Computes the refund for an invalid transaction.
- **`update-data-balance`**: Updates the data balance and ensures the total data in the system does not exceed the global limit.

### Public Functions

The following public functions are available for interaction:

1. **`set-data-price`**: Sets the price for data.
2. **`set-commission-fee`**: Sets the commission fee for transactions.
3. **`set-refund-percentage`**: Sets the refund percentage for invalid transactions.
4. **`set-data-limit`**: Sets the global data limit for the system.
5. **`add-data-for-sale`**: Allows users to list their data for sale at a specified price.
6. **`remove-data-from-sale`**: Allows users to remove their data from the marketplace.
7. **`buy-data-from-user`**: Facilitates data purchase between users.
8. **`refund-data`**: Issues refunds for invalid transactions.
9. **`read-contract-status`**: Retrieves the current data price and balance.
10. **`get-user-balance`**: Retrieves the data and STX balance of a user.
11. **`get-data-for-sale`**: Lists data available for sale.
12. **`check-global-limit`**: Checks the global data limit and current total data.
13. **`get-commission-and-refund-rates`**: Retrieves the current commission and refund rates.

## Error Handling

The contract includes comprehensive error handling to address common issues such as:

- **Owner-Only Access**: Ensures administrative functions are restricted to the contract owner.
- **Insufficient Data or Funds**: Prevents users from performing transactions when they lack the required data or STX balance.
- **Invalid Transactions**: Catches invalid transactions and refunds users where applicable.

## Security

Security mechanisms include:

- **Multi-Factor Authentication (MFA)**: For sensitive updates, the contract requires secure multi-factor authentication to confirm critical actions.
- **Data Limit Enforcements**: Ensures that the total data in the system does not exceed the predefined global limit, preventing system overloads.

## Audit

The contract includes an audit log that allows the owner to track transactions, ensuring transparency and accountability. Every transaction is logged with details such as the sender, receiver, data amount, and the transaction's status.

## Contributing

We welcome contributions to improve the Health Data Marketplace Smart Contract. To contribute:

1. Fork the repository.
2. Submit a pull request with your improvements or fixes.
3. Ensure all tests pass before submitting the PR.

## Licensing

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---