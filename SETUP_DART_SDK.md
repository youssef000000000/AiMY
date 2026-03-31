# Fix "Dart SDK home does not exist"

The error means the path you entered (e.g. `C:\src\flutter\bin\cache\dart-sdk`) is wrong on **your** PC. Do the following.

---

## Step 1: Find where Flutter is installed

Open **Command Prompt** or **PowerShell** and run:

```bat
where flutter
```

- If you see a path like `C:\something\flutter\bin\flutter.bat`, your **Flutter folder** is the part before `\bin`, e.g. `C:\something\flutter`.
- If `where flutter` finds nothing, Flutter is not on your PATH. Check common locations:
  - `C:\src\flutter`
  - `C:\flutter`
  - `%USERPROFILE%\flutter`
  - `%LOCALAPPDATA%\flutter`
  - Where you extracted the Flutter ZIP when you installed it.

---

## Step 2: Create the Dart SDK cache (if needed)

The Dart SDK lives inside Flutter at `bin\cache\dart-sdk`. That folder is created the **first time** you run Flutter.

1. Open a terminal in a folder that has (or will have) a Flutter project, or any folder.
2. Run (use **your** Flutter path from Step 1):

   ```bat
   C:\path\to\flutter\bin\flutter.bat doctor
   ```

   Example: if Flutter is at `C:\flutter`, run:

   ```bat
   C:\flutter\bin\flutter.bat doctor
   ```

3. Wait until it finishes. It will download the Dart SDK into `bin\cache\dart-sdk`.

---

## Step 3: Set Dart SDK path in Android Studio

1. **File → Settings** (or **Ctrl+Alt+S**).
2. **Languages & Frameworks → Dart**.
3. In **Dart SDK path**, click **…** (Browse).
4. Go to your **Flutter folder** → **bin** → **cache** → **dart-sdk** and select the **dart-sdk** folder.
   - Full path will look like: `C:\your\flutter\path\bin\cache\dart-sdk`
5. Check **"Enable Dart support for the project 'AiMY'"**.
6. Check **"Project 'AiMY'"** and **"aimy"** under "Enable Dart support for the following modules".
7. Click **Apply** → **OK**.

The error **"the folder specified as the Dart SDK home does not exist"** will go away once this path points to a real `dart-sdk` folder.

---

## Optional: Set Flutter SDK first (then Dart is filled in)

1. **Languages & Frameworks → Flutter**.
2. Set **Flutter SDK path** to your Flutter folder (e.g. `C:\flutter`), **not** the `dart-sdk` folder.
3. **Apply**.
4. Open **Languages & Frameworks → Dart** again; the Dart SDK path is often set automatically.
