#!/bin/bash
set -e  # Exit on error

# File containing the CSV data
CSV_FILE="testdata2.csv"

# API authentication credentials
USERNAME="admin"
PASSWORD="admin"

# API endpoints
TOKEN_URL="http://localhost:1083/auth/token"
USER_URL="http://localhost:1083/edn/edin/inventory/api/ene/"

# Function to generate the token
generate_token() {
    echo "Generating API token..."
    TOKEN_RESPONSE=$(curl -X GET \
  http://localhost:1083/auth/token \
  -H 'Content-Type: application/json' \
  -d '{
    "username" : "$USERNAME",
    "password" : "$PASSWORD"
}')
    
    # Extract the token from the response
    TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.token')

    if [ -z "$TOKEN" ]; then
        echo "Error: Token Generation Fail"
        exit 1
    fi

    echo "Generated token: $TOKEN"
}

validate_data() {
    unique_key=$1
    echo "Validating data for unique_key: $unique_key"

    while IFS=, read -r key name nodename ipaddress nttype expected_status; do
        if [ "$key" == "$unique_key" ]; then
            # Make the API request with the token
            API_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$USER_URL/$unique_key")

            # Print the raw response for debugging
            echo "API Response: '$API_RESPONSE'"

            if [ -z "$API_RESPONSE" ]; then
                echo "Error: API response is empty"
                exit 1
            fi

            # Storing in Variable
            API_NAME=$(echo $API_RESPONSE | jq -r '.serviceId')
            API_NODENAME=$(echo $API_RESPONSE | jq -r '.nodeNameNt')
            API_IPADDRESS=$(echo $API_RESPONSE | jq -r '.ipAddress')
            API_NTTYPE=$(echo $API_RESPONSE | jq -r '.ntType')

            echo "Expected Name: $name, API Name: $API_NAME"
            echo "Expected nodename: $nodename, API_NODENAME: $API_NODENAME"
            echo "Expected ipaddress: $ipaddress, API_IPADDRESS: $API_IPADDRESS"
            echo "Expected nttype: $nttype, API_NTTYPE: $API_NTTYPE"

            # Validation logic...
            if [ "$name" == "$API_NAME" ]; then
                echo "Name validation: PASS"
            else
                echo "Name validation: FAIL (Expected: $name, Got: $API_NAME)"
            fi

            if [ "$nodename" == "$API_NODENAME" ]; then
                echo "nodename validation: PASS"
            else
                echo "nodename validation: FAIL (Expected: $nodename, Got: $API_NODENAME)"
            fi

            if [ "$ipaddress" == "$API_IPADDRESS" ]; then
                echo "ipaddress validation: PASS"
            else
                echo "ipaddress validation: FAIL (Expected: $ipaddress, Got: $API_IPADDRESS)"
            fi

            if [ "$nttype" == "$API_NTTYPE" ]; then
                echo "nttype validation: PASS"
            else
                echo "nttype validation: FAIL (Expected: $nttype, Got: $API_NTTYPE)"
            fi

            echo "----"
        fi
    done < <(tail -n +2 "$CSV_FILE")
}

# Check if the user provided a unique key
if [ -z "$1" ]; then
    echo "Please provide a unique key."
    exit 1
fi

# Generate the token
generate_token

# Call the function with the provided unique key
validate_data "$1"
