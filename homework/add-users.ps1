# Check if the group already exists
if (Get-LocalGroup -Name "Homework" -ErrorAction SilentlyContinue) {
    Write-Output "Group 'Homework' already exists."
} else {
    # Create a new local group with minimal permissions
    try {
        New-LocalGroup -Name "Homework" -Description "Group with minimal permissions"
        Write-Output "Group 'Homework' created successfully."
    } catch {
        Write-Error "Failed to create group 'Homework': $_"
    }
}

# Function to create a user and add to the group
function CreateUserAndAddToGroup {
    param (
        [string]$userName,
        [string]$fullName,
        [string]$description
    )

    try {
        $password = Read-Host -AsSecureString "Enter password for user $userName"
        New-LocalUser -Name $userName -Password $password -FullName $fullName -Description $description
        Add-LocalGroupMember -Group "Homework" -Member $userName
        Write-Output "User '$userName' created and added to 'Homework' group successfully."
    } catch {
        Write-Error "Failed to create user '$userName' or add to group: $_"
    }
}

# Create user "henry" and assign to the group
CreateUserAndAddToGroup -userName "henry" -fullName "Henry" -description "User Henry"

# Create user "lab0" and assign to the group
CreateUserAndAddToGroup -userName "lab0" -fullName "Lab 0" -description "User Lab0"