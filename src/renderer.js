const { ipcRenderer } = require('electron');

let currentRepoPath = null;
let addCurrentRepoPath = null;

async function checkGitInstallation() {
  const gitCheck = document.getElementById('gitCheck');
  const mainContent = document.getElementById('mainContent');

  const isGitInstalled = await ipcRenderer.invoke('check-git-installed');

  if (isGitInstalled) {
    gitCheck.style.display = 'none';
    mainContent.style.display = 'block';
    loadProfiles();
    loadProfilesForSelect();
  } else {
    gitCheck.innerHTML = `
      <div class="result-box error">
        <h3>Git is not installed</h3>
        <p>Please install Git from <a href="https://git-scm.com/" target="_blank">git-scm.com</a> and restart the application.</p>
      </div>
    `;
  }
}

function setupTabs() {
  const tabButtons = document.querySelectorAll('.tab-button');
  const tabContents = document.querySelectorAll('.tab-content');

  tabButtons.forEach(button => {
    button.addEventListener('click', () => {
      const targetTab = button.getAttribute('data-tab');

      tabButtons.forEach(btn => btn.classList.remove('active'));
      tabContents.forEach(content => content.classList.remove('active'));

      button.classList.add('active');
      document.getElementById(`${targetTab}Tab`).classList.add('active');

      if (targetTab === 'profiles') {
        loadProfiles();
      }
    });
  });
}

async function selectDirectory(isAddForm = false) {
  const dirPath = await ipcRenderer.invoke('select-directory');

  if (dirPath) {
    const isGitRepo = await ipcRenderer.invoke('check-is-git-repo', dirPath);

    if (isAddForm) {
      addCurrentRepoPath = dirPath;
      document.getElementById('addRepoPath').value = dirPath;
      const status = document.getElementById('addRepoStatus');

      if (isGitRepo) {
        status.textContent = 'Valid Git repository';
        status.className = 'status-text success';
      } else {
        status.textContent = 'Not a Git repository';
        status.className = 'status-text error';
        addCurrentRepoPath = null;
      }
    } else {
      currentRepoPath = dirPath;
      document.getElementById('repoPath').value = dirPath;
      const status = document.getElementById('repoStatus');

      if (isGitRepo) {
        status.textContent = 'Valid Git repository';
        status.className = 'status-text success';

        const config = await ipcRenderer.invoke('get-git-config', dirPath);
        if (config.userName) {
          document.getElementById('gitUserName').value = config.userName;
        }
        if (config.email) {
          document.getElementById('email').value = config.email;
        }
      } else {
        status.textContent = 'Not a Git repository (Profile will be created without repo config)';
        status.className = 'status-text';
      }
    }
  }
}

async function handleCreateProfile(event) {
  event.preventDefault();

  const submitBtn = event.target.querySelector('button[type="submit"]');
  const resultDiv = document.getElementById('createResult');

  submitBtn.disabled = true;
  submitBtn.textContent = 'Creating...';

  const formData = {
    name: document.getElementById('profileName').value,
    email: document.getElementById('email').value,
    gitUserName: document.getElementById('gitUserName').value,
    repoPath: currentRepoPath
  };

  try {
    const result = await ipcRenderer.invoke('create-profile', formData);

    resultDiv.className = 'result-box success';
    resultDiv.innerHTML = `
      <h3>Profile Created Successfully!</h3>
      <p>Your SSH key has been generated. Add this public key to your Git provider (GitHub, GitLab, etc.):</p>
      <pre>${result.publicKey}</pre>
      <button class="copy-btn" onclick="copyToClipboard('${result.publicKey.replace(/'/g, "\\'")}')">Copy Public Key</button>
    `;
    resultDiv.style.display = 'block';

    event.target.reset();
    currentRepoPath = null;
    document.getElementById('repoStatus').textContent = '';

    loadProfilesForSelect();
  } catch (error) {
    resultDiv.className = 'result-box error';
    resultDiv.innerHTML = `
      <h3>Error</h3>
      <p>${error.message}</p>
    `;
    resultDiv.style.display = 'block';
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Create Profile';
  }
}

async function handleAddProfile(event) {
  event.preventDefault();

  const submitBtn = event.target.querySelector('button[type="submit"]');
  const resultDiv = document.getElementById('addResult');

  if (!addCurrentRepoPath) {
    resultDiv.className = 'result-box error';
    resultDiv.innerHTML = `
      <h3>Error</h3>
      <p>Please select a valid Git repository</p>
    `;
    resultDiv.style.display = 'block';
    return;
  }

  submitBtn.disabled = true;
  submitBtn.textContent = 'Applying...';

  const formData = {
    profileName: document.getElementById('selectProfile').value,
    repoPath: addCurrentRepoPath
  };

  try {
    await ipcRenderer.invoke('add-profile-to-repo', formData);

    resultDiv.className = 'result-box success';
    resultDiv.innerHTML = `
      <h3>Success!</h3>
      <p>Profile "${formData.profileName}" has been applied to the repository.</p>
    `;
    resultDiv.style.display = 'block';

    event.target.reset();
    addCurrentRepoPath = null;
    document.getElementById('addRepoStatus').textContent = '';
  } catch (error) {
    resultDiv.className = 'result-box error';
    resultDiv.innerHTML = `
      <h3>Error</h3>
      <p>${error.message}</p>
    `;
    resultDiv.style.display = 'block';
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Apply to Repository';
  }
}

async function loadProfiles() {
  const profilesList = document.getElementById('profilesList');
  profilesList.innerHTML = '<div class="loading-spinner"></div><p>Loading profiles...</p>';

  try {
    const profiles = await ipcRenderer.invoke('list-profiles');

    if (profiles.length === 0) {
      profilesList.innerHTML = `
        <div class="empty-state">
          <p>No profiles found. Create your first profile in the "Create Profile" tab.</p>
        </div>
      `;
      return;
    }

    profilesList.innerHTML = '';

    profiles.forEach(profile => {
      const card = document.createElement('div');
      card.className = 'profile-card';
      card.innerHTML = `
        <div class="profile-header">
          <div class="profile-name">${profile.name}</div>
        </div>
        <div class="profile-info">Key: ${profile.keyPath}</div>
        <div class="profile-actions">
          <button onclick="viewPublicKey('${profile.name}')">View Public Key</button>
        </div>
      `;
      profilesList.appendChild(card);
    });
  } catch (error) {
    profilesList.innerHTML = `
      <div class="result-box error">
        <h3>Error</h3>
        <p>Failed to load profiles: ${error.message}</p>
      </div>
    `;
  }
}

async function loadProfilesForSelect() {
  const select = document.getElementById('selectProfile');
  const currentValue = select.value;

  try {
    const profiles = await ipcRenderer.invoke('list-profiles');

    select.innerHTML = '<option value="">-- Select a profile --</option>';

    profiles.forEach(profile => {
      const option = document.createElement('option');
      option.value = profile.name;
      option.textContent = profile.name;
      select.appendChild(option);
    });

    if (currentValue) {
      select.value = currentValue;
    }
  } catch (error) {
    console.error('Failed to load profiles for select:', error);
  }
}

async function viewPublicKey(profileName) {
  const publicKey = await ipcRenderer.invoke('get-public-key', profileName);

  if (publicKey) {
    const profilesList = document.getElementById('profilesList');
    const existingModal = document.querySelector('.modal');
    if (existingModal) {
      existingModal.remove();
    }

    const modal = document.createElement('div');
    modal.className = 'result-box';
    modal.style.marginTop = '16px';
    modal.innerHTML = `
      <h3>Public Key for "${profileName}"</h3>
      <pre>${publicKey}</pre>
      <button class="copy-btn" onclick="copyToClipboard('${publicKey.replace(/'/g, "\\'")}')">Copy Public Key</button>
    `;

    profilesList.insertBefore(modal, profilesList.firstChild);
  }
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    alert('Copied to clipboard!');
  }).catch(err => {
    console.error('Failed to copy:', err);
  });
}

document.getElementById('selectRepoBtn').addEventListener('click', () => selectDirectory(false));
document.getElementById('addSelectRepoBtn').addEventListener('click', () => selectDirectory(true));
document.getElementById('createProfileForm').addEventListener('submit', handleCreateProfile);
document.getElementById('addProfileForm').addEventListener('submit', handleAddProfile);

setupTabs();
checkGitInstallation();
