{
  pkgs,
  lib,
  config,
  configDir,
  ...
}:
{
  options = {
    myhome.vscode.enable = lib.mkEnableOption "enables vscode";
  };

  config = lib.mkIf config.myhome.vscode.enable {
    myhome.myUnfreePackages = [
      "vscode"
      "vscode-extension-ms-vscode-remote-remote-containers"
      "vscode-extension-ms-vscode-remote-remote-ssh"
    ];

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-vscode-remote.remote-containers
          jnoortheen.nix-ide
          eamodio.gitlens
          streetsidesoftware.code-spell-checker
          vscode-icons-team.vscode-icons
          ms-vscode-remote.remote-ssh
        ];
        keybindings = [
          {
            "key" = "shift+alt+f";
            "command" = "editor.action.formatDocument";
            "when" =
              "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
          }
          {
            key = "ctrl+j";
            command = "editor.action.joinLines";
          }
          {
            key = "alt+left";
            command = "workbench.action.navigateBack";
            when = "canNavigateBack";
          }
          {
            key = "alt+right";
            command = "workbench.action.navigateForward";
            when = "canNavigateForward";
          }
          {
            key = "alt+a";
            command = "editor.action.sortLinesAscending";
          }
          {
            key = "alt+d";
            command = "editor.action.sortLinesDescending";
          }
          {
            key = "ctrl+shift+b";
            command = "workbench.action.toggleAuxiliaryBar";
          }
          {
            key = "ctrl+alt+s";
            command = "workbench.action.files.saveWithoutFormatting";
          }
          {
            key = "ctrl+shift+x";
            command = "editor.action.deleteLines";
            when = "textInputFocus && !editorReadonly";
          }
          {
            key = "ctrl+shift+d";
            command = "editor.action.selectHighlights";
            when = "editorFocus";
          }
          {
            key = "ctrl+alt+right";
            command = "cursorWordPartRight";
            when = "textInputFocus && !accessibilityModeEnabled";
          }
          {
            key = "ctrl+alt+left";
            command = "cursorWordPartLeft";
            when = "textInputFocus && !accessibilityModeEnabled";
          }
          {
            key = "ctrl+shift+alt+right";
            command = "cursorWordPartRightSelect";
            when = "textInputFocus && !accessibilityModeEnabled";
          }
          {
            key = "ctrl+shift+alt+left";
            command = "cursorWordPartLeftSelect";
            when = "textInputFocus && !accessibilityModeEnabled";
          }
          {
            key = "ctrl+alt+backspace";
            command = "deleteWordPartLeft";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+alt+delete";
            command = "deleteWordPartRight";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "alt+shift+[";
            command = "runCommands";
            args.commands = [
              "workbench.action.focusSideBar"
              "workbench.action.decreaseViewSize"
              "workbench.action.focusActiveEditorGroup"
            ];
          }
          {
            key = "alt+shift+]";
            command = "runCommands";
            args.commands = [
              "workbench.action.focusSideBar"
              "workbench.action.increaseViewSize"
              "workbench.action.focusActiveEditorGroup"
            ];
          }
          {
            key = "alt+shift+'";
            command = "runCommands";
            args.commands = [
              "workbench.action.terminal.focus"
              "workbench.action.decreaseViewSize"
              "workbench.action.focusActiveEditorGroup"
            ];
          }
          {
            key = "alt+shift+=";
            command = "runCommands";
            args.commands = [
              "workbench.action.terminal.focus"
              "workbench.action.increaseViewSize"
              "workbench.action.focusActiveEditorGroup"
            ];
          }
          {
            "key" = "ctrl+c";
            "command" = "workbench.action.terminal.copySelection";
            "when" =
              "terminalTextSelectedInFocused || terminalFocus && terminalHasBeenCreated && terminalTextSelected || terminalFocus && terminalProcessSupported && terminalTextSelected || terminalFocus && terminalTextSelected && terminalTextSelectedInFocused || terminalHasBeenCreated && terminalTextSelected && terminalTextSelectedInFocused || terminalProcessSupported && terminalTextSelected && terminalTextSelectedInFocused";
          }
          {
            "key" = "ctrl+v";
            "command" = "workbench.action.terminal.paste";
            "when" = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
          }
          {
            "key" = "ctrl+m";
            "command" = "-editor.action.toggleTabFocusMode";
          }
        ];
        userSettings = {
          "accessibility.signalOptions.volume" = 0;
          "chat.commandCenter.enabled" = false;
          "diffEditor.ignoreTrimWhitespace" = false;
          "dev.containers.experimentalMountGitWorktreeCommonDir" = true;
          "editor.dragAndDrop" = false;
          "editor.formatOnSave" = true;
          "editor.hover.delay" = 600;
          "editor.occurrencesHighlight" = "multiFile";
          "editor.snippetSuggestions" = "inline";
          "editor.stickyTabStops" = true;
          "editor.tabCompletion" = "onlySnippets";
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.fileNesting.enabled" = true;
          "explorer.fileNesting.expand" = false;
          "explorer.fileNesting.patterns" = {
            ".env" = "*.env, .env.*, .envrc, env.d.ts";
            ".gitignore" = ".gitattributes, .gitmodules, .gitmessage, .mailmap, .git-blame*";
            "Makefile" = "*.mk";
            "package.json" =
              "package-lock.json, .browserslist*, .editorconfig, .eslint*, tsconfig.*, .node-version, .nodemon*, .npm*, .nvmrc, .pm2*, .pnp.*, .pnpm*, .prettier*, playwright.config.*, vitest.config.*, .stylelint*, .vscode*, bun.lockb, stylelint*, webpack*, biome*, babel*, .commitlint*, .dependency-cruiser.js, knip.json";
            "readme*" =
              "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, RELEASE_NOTES*, Release_Notes*, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, release_notes*, security.md, sponsors*";
            "Readme*" =
              "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, RELEASE_NOTES*, Release_Notes*, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, release_notes*, security.md, sponsors*";
            "README*" =
              "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, RELEASE_NOTES*, Release_Notes*, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, release_notes*, security.md, sponsors*";
            "vite.config.*" =
              "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "app.json" = "eas.json, expo-env.d.ts";
            "*.cs" = "$(capture).*.cs";
            "*.css" = "$(capture).css.map, $(capture).*.css";
            "*.js" = "$(capture).js.map, $(capture).*.js, $(capture)_*.js";
            "*.jsx" =
              "$(capture).js, $(capture).*.jsx, $(capture)_*.js, $(capture)_*.jsx, $(capture).less, $(capture).module.less, $(capture).module.less.d.ts";
            "*.md" = "$(capture).*";
            "*.ts" = "$(capture).js, $(capture).d.ts.map, $(capture).*.ts, $(capture)_*.js, $(capture)_*.ts";
            "*.tsx" =
              "$(capture).ts, $(capture).*.tsx, $(capture)_*.ts, $(capture)_*.tsx, $(capture).less, $(capture).module.less, $(capture).module.less.d.ts, $(capture).scss, $(capture).module.scss, $(capture).module.scss.d.ts";
          };
          "extensions.ignoreRecommendations" = true;
          "files.insertFinalNewline" = true;
          "git.confirmSync" = false;
          "git.decorations.enabled" = true;
          "git.detectWorktrees" = true;
          "git.enableSmartCommit" = true;
          "git.mergeEditor" = true;
          "git.replaceTagsWhenPull" = true;
          "testing.automaticallyOpenTestResults" = "neverOpen";
          "testing.openTesting" = "neverOpen";
          "update.mode" = "none";
          "window.commandCenter" = false;
          "window.confirmSaveUntitledWorkspace" = false;
          "window.customMenuBarAltFocus" = false;
          "window.customTitleBarVisibility" = "never";
          "window.menuBarVisibility" = "hidden";
          "window.restoreWindows" = "none";
          "window.title" = "\${dirty}\${activeEditorShort}\${separator}\${rootNameShort}\${separator}VSCode";
          "window.titleBarStyle" = "native";
          "workbench.activityBar.location" = "top";
          "workbench.editorAssociations" = {
            "git-rebase-todo" = "gitlens.rebase";
          };
          "workbench.iconTheme" = "vscode-icons";
          "workbench.layoutControl.enabled" = false;
          "workbench.layoutControl.type" = "toggles";
          "workbench.secondarySideBar.defaultVisibility" = "hidden";
          "workbench.tree.enableStickyScroll" = true;
          "workbench.browser.openLocalhostLinks" = false;
          "biome.suggestInstallingGlobally" = false;
          "cSpell.language" = "en-GB";
          "cSpell.userWords" = [
            "clearable"
            "cooldown"
            "endregion"
            "falsey"
            "fractionalised"
            "imgur"
            "keychain"
            "KHTML"
            "redactable"
            "reillymc"
            "scrollable"
          ];
          "javascript.preferences.jsxAttributeCompletionStyle" = "braces";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            nixd = {
              formatting = {
                command = [ "nixfmt" ];
              };
              options = {
                nixos = {
                  "expr" =
                    "let f = builtins.getFlake \"${configDir}\"; nixpkgs = f.inputs.nixpkgs; in (import (nixpkgs + \"/nixos/lib/eval-config.nix\") { system = \"x86_64-linux\"; modules = [ { _module.check = false; } \"${configDir}/modules/nixos\" ]; }).options";
                };
                "home-manager" = {
                  "expr" =
                    "let f = builtins.getFlake \"${configDir}\"; nixpkgs = f.inputs.nixpkgs; pkgs = import nixpkgs { system = \"x86_64-linux\"; }; hm = f.inputs.home-manager; extendedLib = import (hm + \"/modules/lib/stdlib-extended.nix\") nixpkgs.lib; hmModules = import (hm + \"/modules/modules.nix\") { inherit pkgs; lib = extendedLib; check = false; minimal = false; }; hmEval = extendedLib.evalModules { modules = [ { home.stateVersion = \"25.05\"; } \"${configDir}/modules/home-manager\" ] ++ hmModules; class = \"homeManager\"; specialArgs = { modulesPath = toString (hm + \"/modules\"); configDir = \"/fake/configDir\"; theme = \"dark\"; }; }; in hmEval.options";
                };
              };
            };
          };
          "remote.SSH.enableAgentForwarding" = true;
          "typescript.preferences.jsxAttributeCompletionStyle" = "auto";
          "typescript.preferences.preferTypeOnlyAutoImports" = true;
          "typescript.preferences.useAliasesForRenames" = false;
          "redhat.telemetry.enabled" = false;
          "vsicons.dontShowNewVersionMessage" = true;
          "[markdown]" = {
            "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
          };
          "[nix]" = {
            "editor.defaultFormatter" = "jnoortheen.nix-ide";
          };
          "[svg]" = {
            "editor.defaultFormatter" = "jock.svg";
          };
          "[snippets]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
          };
          "scm.diffDecorationsGutterPattern" = {
            "modified" = false;
          };
          "dev.containers.defaultExtensions" = [
            "eamodio.gitlens"
            "streetsidesoftware.code-spell-checker"
          ];
          "dev.containers.defaultFeatures" = {
            "ghcr.io/reillymc/personal-devcontainer-features/opencode:0" = { };
          };
          "dev.containers.lockfile" = false;
          "remote.SSH.defaultExtensions" = [
            "eamodio.gitlens"
            "streetsidesoftware.code-spell-checker"
            "jnoortheen.nix-ide"
          ];
          "editor.linkedEditing" = true;
          "editor.selectionClipboard" = false; # enabled middle click cursor (disables paste)
          "window.menuStyle" = "custom"; # native context menu is scaled too large
          "remote.autoForwardPortsSource" = "hybrid"; # vscode keeps auto-setting this
          "remote.localPortHost" = "allInterfaces"; # bind forwarded ports on all interfaces so the dev servers are reachable from tailnet/LAN
          "json.schemaDownload.trustedDomains" = {
            "https://schemastore.azurewebsites.net/" = true;
            "https://raw.githubusercontent.com/" = true;
            "https://www.schemastore.org/" = true;
            "https://json.schemastore.org/" = true;
            "https://json-schema.org/" = true;
            "https://biomejs.dev/" = true;
            "https://unpkg.com/" = true;
          };
          "chat.viewSessions.orientation" = "stacked";
          "chat.disableAIFeatures" = false;
          "github.copilot.enable" = {
            "*" = false;
          };

        };
        languageSnippets = {
          "typescriptreact" = {
            "Function Component" = {
              prefix = "fc";
              body = [
                "import { FC } from \"react\";"
                ""
                "interface \${TM_FILENAME_BASE/(.*)/\${1:/pascalcase}/}Props {"
                ""
                "}"
                ""
                "export const \${TM_FILENAME_BASE/(.*)/\${1:/pascalcase}/}: FC<\${TM_FILENAME_BASE/(.*)/\${1:/pascalcase}/}Props> = ({}) => {"
                "    "
                ""
                "    return ("
                "        $1"
                "    );"
                "};"
                ""
              ];
              description = "Function Component";
            };
          };
          "typescript" = {
            "Export" = {
              "prefix" = "ex";
              "body" = [
                "export { $2 } from \"./$1\";"
                ""
              ];
              "description" = "Module Index";
            };
          };
        };
      };
    };

    home.packages = with pkgs; [
      nixfmt
      nixd
    ];

    xdg.desktopEntries."vscode-devvm" = {
      name = "VSCode (devvm)";
      comment = "Code on the devvm over Remote SSH";
      exec = "code --remote ssh-remote+devvm";
      icon = "vscode";
      terminal = false;
      categories = [
        "Development"
        "IDE"
      ];
      startupNotify = true;
    };
  };
}
