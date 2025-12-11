# Creating WRF Lengau GitHub Repository

## Steps to Create Repository

1. **Go to GitHub**: https://github.com/new

2. **Repository Settings**:
   - Repository name: `wrf-lengau`
   - Description: "WRF installation scripts for Lengau cluster"
   - Visibility: Public (or Private)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)

3. **Create Repository**

4. **Push Local Repository**:

```bash
cd wrf-lengau

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/wrf-lengau.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Using Personal Access Token

If prompted for authentication:

1. Create a Personal Access Token (PAT) on GitHub:
   - Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` scope

2. Use token as password when pushing:
   ```bash
   git push -u origin main
   # Username: YOUR_USERNAME
   # Password: YOUR_PAT_TOKEN
   ```

## Alternative: SSH Authentication

```bash
# Add SSH remote
git remote set-url origin git@github.com:YOUR_USERNAME/wrf-lengau.git

# Push
git push -u origin main
```

