{
  flake.modules.homeManager.skills =
    { config, lib, ... }:
    let
      cfg = config.skills;

      # Always-on skills deployed to every host that imports this bucket.
      builtinSkills = {
        writing-skills = ./_skills/writing-skills;
        warehouse-ux-pr-review = ./_skills/warehouse-ux-pr-review;
        html-report = ./_skills/html-report;
        ado-pr-markdown = ./_skills/ado-pr-markdown;
        context-reflect = ./_skills/context-reflect;
      };

      # Opt-in skills, enabled via `skills.extra = [ "figma-to-spec" ];`.
      availableSkills = {
        figma-to-spec = ./_skills/figma-to-spec;
        fluent-ui-v9 = ./_skills/fluent-ui-v9;
      };

      enabled = builtinSkills // lib.getAttrs cfg.extra availableSkills;
      skillsDir = "${config.home.homeDirectory}/.agents/skills";
    in
    {
      options.skills.extra = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (lib.attrNames availableSkills));
        default = [ ];
        description = "Optional skills to deploy in addition to the built-ins.";
      };

      config = {
        home.file = lib.mapAttrs' (
          name: src:
          lib.nameValuePair ".agents/skills/${name}" {
            source = src;
            recursive = true;
          }
        ) enabled;

        home.sessionVariables.AGENTS_SKILLS_DIR = skillsDir;
      };
    };
}
