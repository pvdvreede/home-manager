{...}: {
  flake.homeModules.gh-dash = {...}: {
    programs.gh-dash = {
      enable = true;
      settings = {
        prSections = [
          {
            title = "My Pull Requests";
            filters = "is:open author:@me";
          }
          {
            title = "Needs My Review";
            filters = "is:open review-requested:@me";
          }
          {
            title = "Involved";
            filters = "is:open involves:@me -author:@me";
          }
        ];
        issuesSections = [
          {
            title = "My Issues";
            filters = "is:open author:@me";
          }
          {
            title = "Assigned";
            filters = "is:open assignee:@me";
          }
        ];
        defaults = {
          preview.open = true;
          prsLimit = 50;
          issuesLimit = 50;
          view = "prs";
        };
      };
    };
  };
}
