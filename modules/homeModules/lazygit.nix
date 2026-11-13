{...}: {
  flake.homeModules.lazygit = {...}: {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          scrollHeight = 2;
          scrollPastBottom = true;
          mouseEvents = true;
          sidePanelWidth = 0.3333;
          expandFocusedSidePanel = false;
          mainPanelSplitMode = "flexible";
          wrapLinesInDiffView = true;
          language = "auto";
          timeFormat = "02 Jan 06";
          shortTimeFormat = "3:04PM";
          colorScheme = "auto";
          theme = {
            activeBorderColor = ["green" "bold"];
            inactiveBorderColor = ["default"];
            selectedLineBgColor = [];
          };
          showFileTree = true;
          showRandomTip = true;
          showCommandLog = true;
          showBottomLine = true;
          nerdFontsVersion = "";
          showFileIcons = true;
          commitHashLength = 8;
          showBranchCommitHash = false;
          showDivergenceFromBaseBranch = "none";
          splitDiff = "auto";
          screenMode = "normal";
          border = "rounded";
          animateExplosion = true;
          portraitMode = "auto";
          filterMode = "substring";
          statusPanelView = "dashboard";
        };
        git = {
          diffRenderers = [];
          commit = {
            signOff = false;
            autoWrapCommitMessage = true;
            autoWrapWidth = 72;
          };
          merging = {
            manualCommit = false;
            args = "";
          };
          mainBranches = ["master" "main"];
          skipHookPrefix = "WIP";
          autoFetch = true;
          autoRefresh = true;
          autoForwardBranches = "onlyMainBranches";
          fetchAll = true;
          autoStageResolvedConflicts = true;
          ignoreWhitespaceInDiffView = false;
          diffContextSize = 3;
          overrideGpg = false;
          disableForcePushing = false;
          branchPrefix = "";
          parseEmoji = false;
          log = {
            order = "topo-order";
            showGraph = "always";
            showWholeGraph = false;
          };
          localBranchSortOrder = "date";
          remoteBranchSortOrder = "date";
        };
        update = {
          method = "never";
        };
        refresher = {
          refreshInterval = 10;
          fetchInterval = 60;
        };
        os = {
          editPreset = "";
          edit = "";
          open = "";
          openLink = "";
        };
        confirmOnQuit = false;
        quitOnTopLevelReturn = false;
        disableStartupPopups = false;
        notARepository = "prompt";
        promptToReturnFromSubprocess = true;
        customCommands = [];
      };
    };
  };
}
