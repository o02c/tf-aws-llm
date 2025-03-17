#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import argparse
import unicodedata
from pathlib import Path
from bs4 import BeautifulSoup
from datetime import datetime

def extract_transactions(html_file):
    """
    Extract transaction data from Money Forward Cloud Accounting HTML file
    Returns a list of dictionaries with date, amount, and description
    """
    # Read the HTML file
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # Parse HTML with BeautifulSoup
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Find all transaction rows (act-list elements)
    transaction_rows = soup.find_all('div', class_='act-list')
    
    transactions = []
    
    for row in transaction_rows:
        try:
            # Extract date (format MM/DD)
            date_input = row.find('input', {'id': 'act_recognized_at'})
            if not date_input or not date_input.get('value'):
                continue
            date_str = date_input.get('value')
            
            # Extract amount
            amount_input = row.find('input', {'id': 'act_branches__value'})
            if not amount_input or not amount_input.get('value'):
                continue
            amount_str = amount_input.get('value').replace(',', '')
            
            # Convert to number (handle negative values with - prefix)
            try:
                amount = float(amount_str)
            except ValueError:
                # Skip if amount cannot be converted to float
                continue
            
            # Extract description
            description_elem = row.find('textarea', {'id': 'act_branches__remark'})
            if not description_elem:
                continue
            description = description_elem.text.strip()
            
            # Convert full-width characters to half-width
            description = unicodedata.normalize('NFKC', description)
            
            # Handle date formatting
            date_parts = date_str.split('/')
            if len(date_parts) == 2:
                # Only month and day provided, add the current year
                month, day = date_parts
                # Use current year, but if month is greater than current month, use previous year
                current_year = datetime.now().year
                current_month = datetime.now().month
                
                if int(month) > current_month:
                    # This is likely a transaction from the previous year
                    year = current_year - 1
                else:
                    year = current_year
                    
                full_date = f"{year}/{month}/{day}"
            elif len(date_parts) == 3:
                # Full date already provided (YYYY/MM/DD)
                full_date = date_str
            else:
                # Invalid date format, skip this transaction
                continue
            
            # Create transaction record
            transaction = {
                'date': full_date,
                'amount': amount,
                'description': description
            }
            transactions.append(transaction)
        except Exception as e:
            print(f"Error processing a transaction: {e}")
            continue
    
    return transactions

def save_to_csv(transactions, output_file):
    """
    Save transactions to a CSV file
    """
    if not transactions:
        print("No transactions found to save")
        return False
    
    # Sort transactions by date (newest first)
    sorted_transactions = sorted(transactions, key=lambda x: x['date'], reverse=True)
    
    fieldnames = ['date', 'amount', 'description']
    
    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for transaction in sorted_transactions:
            # Format amount as integer
            formatted_transaction = transaction.copy()
            formatted_transaction['amount'] = str(int(transaction['amount']))
            writer.writerow(formatted_transaction)
    
    return True

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Extract transactions from Money Forward Cloud Accounting HTML file')
    parser.add_argument('--input', '-i', default='/Users/o2c/ghq/github.com/o02c/tf-aws-llm/data.html',
                        help='Path to the HTML file')
    parser.add_argument('--output', '-o', default='/Users/o2c/ghq/github.com/o02c/tf-aws-llm/transactions.csv',
                        help='Path to the output CSV file')
    parser.add_argument('--year', '-y', type=int, default=datetime.now().year,
                        help='Default year to use for dates without year (default: current year)')
    args = parser.parse_args()
    
    html_file = args.input
    output_file = args.output
    
    # Check if input file exists
    input_path = Path(html_file)
    if not input_path.exists():
        print(f"Error: Input file '{html_file}' does not exist")
        return
    
    # Extract transactions
    print(f"Extracting transactions from {html_file}...")
    transactions = extract_transactions(html_file)
    
    # Print summary
    print(f"Found {len(transactions)} transactions")
    
    # Save to CSV
    if save_to_csv(transactions, output_file):
        print(f"Transactions saved to {output_file}")
    else:
        print("Failed to save transactions")
        
    # Print sample of transactions
    if transactions:
        print("\nSample transactions:")
        for i, t in enumerate(transactions[:5]):
            print(f"{i+1}. Date: {t['date']}, Amount: {t['amount']}, Description: {t['description']}")
        if len(transactions) > 5:
            print(f"... and {len(transactions) - 5} more transactions")

if __name__ == "__main__":
    main()
