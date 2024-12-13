#!/bin/bash
# List all IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

echo "Users with AWS Management Console access:"

# Check each user for console access
for user in $users; do
    # Check if the user has a login profile
    aws iam get-login-profile --user-name $user > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        # If the command succeeds, the user has console access
        echo "User: $user has console access"
        # Get the console URL for the user (this needs additional permissions and configuration to get the actual console URL)
        # Note: AWS does not provide a direct way to get a specific console URL via CLI for each user.
        # But generally, it's like: https://<account-id>.signin.aws.amazon.com/console for regular console
        # Use your account specific URL for each user if configured.
    fi
done

