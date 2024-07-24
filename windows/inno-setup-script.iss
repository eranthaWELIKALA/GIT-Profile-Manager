[Setup]
AppName=Git Profile Manager
AppVersion=1.0
DefaultDirName={pf}\GitProfileManager
DefaultGroupName=Git Profile Manager
OutputDir=.\output
OutputBaseFilename=GitProfileManagerInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "E:\Erantha\Personal\MyProjects\WindowsGitProfileManager\git-profile-manager.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Erantha\Personal\MyProjects\WindowsGitProfileManager\git-profile-add.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Erantha\Personal\MyProjects\WindowsGitProfileManager\git-profile-create.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Erantha\Personal\MyProjects\WindowsGitProfileManager\What to do after creating an SSH Key.pdf"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Git Profile Manager"; Filename: "{app}\git-profile-manager.bat"; WorkingDir: "{app}"

[InstallDelete]
Type: files; Name: "{app}\*.*"

[Code]
function ReadEnvironmentVariable(const VarName: String; var Value: String): Boolean;
begin
  Result := RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', VarName, Value);
end;

procedure WriteEnvironmentVariable(const VarName, Value: String);
begin
  RegWriteStringValue(HKEY_CURRENT_USER, 'Environment', VarName, Value);
end;

function EnsureTrailingBackslash(const Path: String): String;
begin
  Result := Path;
  // Check if the path does not end with a backslash
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then
    Result := Result + '\';
end;

procedure UpdatePathEnvVariable;
var
  CurrentPath: String;
  NewPath: String;
  UpdatedPath: String;
begin
  // Ensure the environment variable is read correctly
  if ReadEnvironmentVariable('Path', CurrentPath) then
  begin
    NewPath := EnsureTrailingBackslash(ExpandConstant('{app}'));

    // Concatenate paths correctly
    if CurrentPath <> '' then
    begin
      UpdatedPath := CurrentPath + ';' + NewPath;
    end
    else
    begin
      UpdatedPath := NewPath;
    end;

    // Update the PATH environment variable
    WriteEnvironmentVariable('Path', UpdatedPath);

    // Notify the user
    MsgBox('PATH environment variable updated. You might need to restart any open command prompts or your computer for the changes to take effect.', mbInformation, MB_OK);
  end
  else
  begin
    // Handle the error if needed
    MsgBox('Failed to read the PATH environment variable.', mbError, MB_OK);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    UpdatePathEnvVariable;
  end;
end;
