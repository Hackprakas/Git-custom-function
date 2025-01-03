
# GitHub PowerShell CLI Functions

This repository contains a collection of PowerShell functions designed to enhance your GitHub workflow. These functions interact with the GitHub CLI (`gh`), so **GitHub CLI must be installed** before using them.

## Prerequisites

1. **Install GitHub CLI**:
   - GitHub CLI (gh) is required for all the functions in this script. You can install it from [GitHub CLI](https://cli.github.com/).

2. **Save the Profile Script**:
   - After downloading this repository, save the `profile.ps1` script in your **Documents folder** in Windows (e.g., `C:\Users\<YourUsername>\Documents\profile.ps1`).
   - This will ensure that all the functions are loaded automatically into your PowerShell session when it starts.

## Functions

Here’s a list of the available functions and their usage:

### 1. **`list_repo`**
   Lists all repositories in your GitHub account along with their visibility status (public or private).

   **Usage**:
   ```powershell
   list_repo
   ```

   **Output**:
   Displays a table with repository names on the left and visibility (public or private) on the right.

### 2. **`relogin`**
   Logs out the current GitHub user and prompts the user to log in with a new GitHub account.

   **Usage**:
   ```powershell
   relogin
   ```

   **Process**:
   - Logs out the current user.
   - Asks if you want to log in with a new account.

### 3. **`delete_repo`**
   Deletes a GitHub repository after asking for confirmation.

   **Usage**:
   ```powershell
   delete_repo <repoName>
   ```

   **Process**:
   - Asks for confirmation to delete the repository.
   - Deletes the repository from GitHub after confirmation.

### 4. **`create_repo`**
   Creates a new GitHub repository with a specified name, visibility (public or private), and initial commit message.

   **Usage**:
   ```powershell
   create_repo <repoName>
   ```

   **Process**:
   - Prompts for commit message and visibility.
   - Creates a new GitHub repository with the specified name and visibility.
   - Commits and pushes the changes to GitHub.

### 5. **`switchto`**
   Switches to an existing branch or creates a new one if it doesn’t exist.

   **Usage**:
   ```powershell
   switchto <branchName>
   ```

   **Process**:
   - Checks if the branch exists.
   - Switches to the branch if it exists, or creates and switches to a new one if it doesn't.


### 6. **`delete_branch`**
   Deletes a local or remote Git branch.

   **Usage**:
   ```powershell
   delete_branch <branchName> [-localonly]
   ```

   **Process**:
   - Deletes the specified branch locally.
   - Optionally deletes the branch remotely if `-localonly` is not specified.

### 7. **`remove_member`**
   Removes a user from a GitHub repository's team or collaborators list.

   **Usage**:
   ```powershell
   remove_member <user1>,<user2>
   ```

   **Process**:
   - Removes the specified users from the repository’s team or collaborators.
   - the user specified should be github username and not github email id of the user.

### 8. **`add_member`**
   Adds a user to a GitHub repository's team or collaborators list.

   **Usage**:
   ```powershell
   add_member <user1>,<user2>
   ```

   **Process**:
   - Adds the specified users to the repository’s team or collaborators.
   - It should be github username and not github user email.

### 9. **`pull`**
   Pulls the latest changes from the current branch in the remote repository.

   **Usage**:
   ```powershell
   pull
   ```

   **Process**:
   - Pulls the latest changes from the remote repository to the current branch.

### 10. **`push`**
   Pushes committed changes from the local repository to the remote repository.Also pulls any remote changes

   **Usage**:
   ```powershell
   push <commitmessage>
   ```

### 11.**`change_visibility`**
   Changes the visibility of a specified Git repository to either "public" or "private."  
   If the visibility is already set to the specified option, no changes are made, and the user is notified.  
   The function infers the repository name from the `.git` folder in the current directory. If no Git folder is found, it prompts the user to enter a repository name.

   **Usage**:
   ```powershell
   change_visibility <visibility>
   ```
   - `<visibility>`: Set to `public` or `private` to specify the desired repository visibility.

   **Example**:
   ```powershell
   change_visibility public
   ```

   **Behavior**:
   - **Repository Found in Current Directory**: The function changes the repository’s visibility only if it differs from the specified value. If the visibility is already set, the user is notified.
   - **No Repository in Current Directory**: Prompts the user to enter a repository name if no `.git` folder is detected.
   
   **Output**:
   Displays a confirmation message if visibility is changed or a notification if no change was needed.

### 12. **`set_default_branch`**
   Changes the default branch of the current GitHub repository.

   **Usage**:
   ```powershell
   set_default_branch <branchName>
   ```

## Notes
- **GitHub CLI (gh)** must be installed for these functions to work.
- The `profile.ps1` script should be saved in your **Documents folder** (e.g., `C:\Users\<YourUsername>\Documents\profile.ps1`) for it to be loaded automatically in PowerShell.

#
