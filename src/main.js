const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const os = require('os');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    backgroundColor: '#1a1a1a',
    titleBarStyle: 'default',
    icon: path.join(__dirname, 'assets', 'icon.png')
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

ipcMain.handle('check-git-installed', async () => {
  return new Promise((resolve) => {
    exec('git --version', (error) => {
      resolve(!error);
    });
  });
});

ipcMain.handle('check-is-git-repo', async (event, dirPath) => {
  const gitDir = path.join(dirPath, '.git');
  return fs.existsSync(gitDir);
});

ipcMain.handle('select-directory', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory']
  });

  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0];
  }
  return null;
});

ipcMain.handle('list-profiles', async () => {
  const sshDir = path.join(os.homedir(), '.ssh');

  if (!fs.existsSync(sshDir)) {
    return [];
  }

  const files = fs.readdirSync(sshDir);
  const profiles = [];

  files.forEach(file => {
    if (file.startsWith('id_rsa_') && !file.endsWith('.pub')) {
      const profileName = file.replace('id_rsa_', '');
      const keyPath = path.join(sshDir, file);
      const pubKeyPath = keyPath + '.pub';

      if (fs.existsSync(pubKeyPath)) {
        profiles.push({
          name: profileName,
          keyPath: keyPath,
          pubKeyPath: pubKeyPath
        });
      }
    }
  });

  return profiles;
});

ipcMain.handle('create-profile', async (event, data) => {
  const { name, email, gitUserName, repoPath } = data;

  return new Promise((resolve, reject) => {
    const sshDir = path.join(os.homedir(), '.ssh');
    const keyPath = path.join(sshDir, `id_rsa_${name}`);

    if (!fs.existsSync(sshDir)) {
      fs.mkdirSync(sshDir, { recursive: true });
    }

    if (fs.existsSync(keyPath)) {
      reject(new Error('A profile with this name already exists'));
      return;
    }

    const command = `ssh-keygen -t rsa -C "${email}" -f "${keyPath}" -N ""`;

    exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(`Failed to generate SSH key: ${error.message}`));
        return;
      }

      const publicKey = fs.readFileSync(keyPath + '.pub', 'utf8');

      if (repoPath) {
        const gitConfigCommands = [
          `cd "${repoPath}" && git config user.name "${gitUserName}"`,
          `cd "${repoPath}" && git config user.email "${email}"`,
          `cd "${repoPath}" && git config core.sshCommand "ssh -i \\"${keyPath}\\""`
        ];

        exec(gitConfigCommands.join(' && '), (configError) => {
          if (configError) {
            reject(new Error(`SSH key created but Git config failed: ${configError.message}`));
            return;
          }

          resolve({
            success: true,
            publicKey: publicKey,
            keyPath: keyPath
          });
        });
      } else {
        resolve({
          success: true,
          publicKey: publicKey,
          keyPath: keyPath
        });
      }
    });
  });
});

ipcMain.handle('add-profile-to-repo', async (event, data) => {
  const { profileName, repoPath } = data;

  return new Promise((resolve, reject) => {
    const keyPath = path.join(os.homedir(), '.ssh', `id_rsa_${profileName}`);

    if (!fs.existsSync(keyPath)) {
      reject(new Error('Profile SSH key not found'));
      return;
    }

    const command = `cd "${repoPath}" && git config core.sshCommand "ssh -i \\"${keyPath}\\""`;

    exec(command, (error) => {
      if (error) {
        reject(new Error(`Failed to configure Git: ${error.message}`));
        return;
      }

      resolve({ success: true });
    });
  });
});

ipcMain.handle('get-public-key', async (event, profileName) => {
  const pubKeyPath = path.join(os.homedir(), '.ssh', `id_rsa_${profileName}.pub`);

  if (fs.existsSync(pubKeyPath)) {
    return fs.readFileSync(pubKeyPath, 'utf8');
  }

  return null;
});

ipcMain.handle('get-git-config', async (event, repoPath) => {
  return new Promise((resolve) => {
    exec(`cd "${repoPath}" && git config --get user.name && git config --get user.email`,
      (error, stdout) => {
        if (error) {
          resolve({ userName: '', email: '' });
          return;
        }

        const lines = stdout.trim().split('\n');
        resolve({
          userName: lines[0] || '',
          email: lines[1] || ''
        });
      });
  });
});
