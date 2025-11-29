# GitHub Repository Setup Guide

## Step 1: Initialize Git Repository

```bash
cd /home/nikhil/HW7

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "HW7: PKI Infrastructure and TLS Certificate Setup

- Created Root CA, Signing CA, and TLS certificate
- Configured Apache Tomcat with SSL/TLS
- Complete documentation included
- All certificates and keystores generated"
```

## Step 2: Create GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Sign in** to your account (or create one if you don't have one)
3. **Click the "+" icon** in the top right corner
4. **Select "New repository"**

## Step 3: Configure Repository Settings

**Repository Settings:**
- **Repository name**: `HW7-PKI-Infrastructure` (or any name you prefer)
- **Description**: "HW7 Security Assignment - PKI Infrastructure with Root CA, Signing CA, and TLS Certificate"
- **Visibility**: 
  - **Public** (if allowed by your course) - easier to share
  - **Private** (if you prefer) - you can still share the link with instructors
- **DO NOT** initialize with README, .gitignore, or license (we already have files)

Click **"Create repository"**

## Step 4: Connect Local Repository to GitHub

After creating the repository, GitHub will show you commands. Use these:

```bash
cd /home/nikhil/HW7

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/HW7-PKI-Infrastructure.git

# Or if using SSH:
# git remote add origin git@github.com:YOUR_USERNAME/HW7-PKI-Infrastructure.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note**: You'll be prompted for your GitHub username and password (or personal access token if using HTTPS).

## Step 5: Get Your Repository URL

Your repository URL will be:
```
https://github.com/YOUR_USERNAME/HW7-PKI-Infrastructure
```

**Example**: If your username is `nikhil123`, your URL would be:
```
https://github.com/nikhil123/HW7-PKI-Infrastructure
```

## Step 6: Update Submission Document

In your `HW7_SUBMISSION.md` file, update the GitHub Repository section:

```markdown
## 9. GitHub Repository

**Repository URL:** https://github.com/YOUR_USERNAME/HW7-PKI-Infrastructure

**Repository Structure:**
[Your repository will have all the files listed here]
```

## Alternative: Using GitHub CLI (gh)

If you have GitHub CLI installed:

```bash
# Authenticate
gh auth login

# Create repository and push
gh repo create HW7-PKI-Infrastructure --public --source=. --remote=origin --push
```

## What to Commit

**Important files to include:**
- ✅ All documentation (.md files)
- ✅ All scripts (.sh files)
- ✅ PKI configuration files (pki-example-1/etc/*.conf)
- ✅ Certificate files (optional, but good for demonstration)
- ✅ README.md

**Optional - You can exclude:**
- Private keys (if you want - but including them shows the complete setup)
- Large binary files (but JKS and P12 are small, so fine to include)

## Quick Setup Script

You can run this to set everything up (after creating the GitHub repo):

```bash
cd /home/nikhil/HW7

# Initialize and commit
git init
git add .
git commit -m "HW7: PKI Infrastructure and TLS Certificate Setup"

# Add remote (UPDATE YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

## Troubleshooting

### If you get "fatal: remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
```

### If you need to update your repository
```bash
git add .
git commit -m "Update documentation"
git push
```

### To check your remote URL
```bash
git remote -v
```

## Privacy Considerations

- **Public repository**: Anyone can see your code
- **Private repository**: Only you (and people you invite) can see it
- **For assignment**: Both are fine, check with your instructor

If private, you can still share the link - instructors can view it if you give them access or they can ask you to make it temporarily public.

## Final Checklist

- [ ] Git repository initialized
- [ ] All files committed
- [ ] GitHub repository created
- [ ] Local repo connected to GitHub
- [ ] Code pushed to GitHub
- [ ] Repository URL copied
- [ ] Submission document updated with GitHub URL
- [ ] Tested the repository URL (open in browser)

