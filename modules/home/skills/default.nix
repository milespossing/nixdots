{
  config,
  lib,
  ...
}:
let
  cfg = config.my.skills;

  # Built-in skills shipped with this module. Each entry maps a skill
  # name to the directory containing its SKILL.md. These are deployed
  # on every host that imports this module.
  builtinSkills = {
    writing-skills = ./skills/writing-skills;
    warehouse-ux-pr-review = ./skills/warehouse-ux-pr-review;
  };

  # Optional skills shipped with this module that hosts can opt into,
  # e.g. `my.skills.extraSkills = [ "wsl-browser-control" ];`.
  availableSkills = {
    wsl-browser-control = ./skills/wsl-browser-control;
    figma-to-spec = ./skills/figma-to-spec;
    fluent-ui-v9 = ./skills/fluent-ui-v9;
  };

  # ~/.agents/skills/<name>
  skillsDir = "${config.home.homeDirectory}/.agents/skills";

  mkSkillFile = name: source: {
    name = ".agents/skills/${name}";
    value = {
      source = source;
      recursive = true;
    };
  };

  enabledSkills = lib.filterAttrs (_: v: v.enable) cfg.skills;
in
{
  options.my.skills = {
    enable = lib.mkEnableOption "Deploy agent skills to ~/.agents/skills";

    extraSkills = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames availableSkills));
      default = [ ];
      example = [ "wsl-browser-control" ];
      description = ''
        Names of optional built-in skills to enable on this host, in
        addition to the always-on built-ins. Available: ${lib.concatStringsSep ", " (lib.attrNames availableSkills)}.
      '';
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to deploy this skill.";
              };
              source = lib.mkOption {
                type = lib.types.path;
                description = ''
                  Path to the skill directory. Must contain a SKILL.md file
                  with YAML frontmatter (name + description required).
                  See https://agentskills.io/specification.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = "Set of skills to deploy under ~/.agents/skills.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Register the built-in skills. Users can disable any by setting
    # `my.skills.skills.<name>.enable = false;`.
    my.skills.skills =
      lib.mapAttrs (_: src: { source = src; }) builtinSkills
      // lib.mapAttrs (_: src: { source = src; }) (lib.getAttrs cfg.extraSkills availableSkills);

    home.file = lib.mapAttrs' (n: v: mkSkillFile n v.source) enabledSkills;

    home.sessionVariables = {
      AGENTS_SKILLS_DIR = skillsDir;
    };
  };
}
