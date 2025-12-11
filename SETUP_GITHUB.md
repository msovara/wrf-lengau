# Setting Up GitHub Repository for WRF Lengau

## Prerequisites

- GitHub account
- Git installed locally
- Repository files ready

## Step-by-Step Instructions

### 1. Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `wrf-lengau`
3. Description: "WRF installation scripts for Lengau cluster"
4. Visibility: Choose Public or Private
5. **Do NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

### 2. Initialize Local Repository

```bash
cd wrf-lengau

# Initialize git (if not already done)
git init

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: WRF installation scripts for Lengau cluster"
```

### 3. Connect to GitHub

```bash
# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/wrf-lengau.git

# Verify remote
git remote -v
```

### 4. Push to GitHub

```bash
# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

### 5. Authentication

If prompted for credentials:

**Option A: Personal Access Token (PAT)**
1. Create PAT: GitHub → Settings → Developer settings → Personal access tokens
2. Generate token with `repo` scope
3. Use token as password when pushing

**Option B: SSH**
```bash
# Change remote to SSH
git remote set-url origin git@github.com:YOUR_USERNAME/wrf-lengau.git

# Push
git push -u origin main
```

## Verification

After pushing, verify:
- Repository is visible on GitHub
- All files are present
- README displays correctly

## Next Steps

- Add repository description
- Set up topics/tags
- Create releases for versions
- Add collaborators if needed

