# Overlay: pkgs.agenticSkills — declarative agent skill "packages".
#
# Each skill is an attrset matching the home-manager skillType option shape.
# Use fetchSkillFromGitHub for third-party skills and mkSkillFromFile for
# local SKILL.md files stored in this directory tree.
final: prev:
let
  aiLib = import ../../modules/home/ai/lib.nix {
    lib = final.lib;
    pkgs = final;
  };
in
{
  agenticSkills = {
    # OSFTA — "One Skill to Find Them All"
    # Discovers OpenCode plugins and skills by searching curated catalogs.
    # https://github.com/itsrainingmani/OSFTA
    discover-plugins = aiLib.fetchSkillFromGitHub {
      owner = "itsrainingmani";
      repo = "OSFTA";
      rev = "0ae14084abc1b449a9e5069d3583882aed655c71";
      path = "skill/discover-plugins/SKILL.md";
      hash = "sha256-tf2wDKxXDcLIMa+ShSVPW60ubqRs9E6ibn/+WhwPsL4=";
    };

    # SkillsMP — search the SkillsMP marketplace for agent skills.
    # Requires SKILLSMP_API_KEY in the environment.
    # https://skillsmp.com
    skillsmp-search = aiLib.mkSkillFromFile ./skillsmp-search/SKILL.md;

    # Install skill — how to add, remove, or update agent skills in this repo.
    install-skill = aiLib.mkSkillFromFile ./install-skill/SKILL.md;

    # Azure CLI — comprehensive Azure Cloud Platform management via CLI.
    # https://github.com/openclaw/skills/tree/main/skills/ddevaal/azure-cli
    az-cli = aiLib.fetchSkillFromGitHubFile {
      owner = "openclaw";
      repo = "skills";
      rev = "26b2d3a283940b92d5fdcbac9295bb255821f27b";
      path = "skills/ddevaal/azure-cli/SKILL.md";
      hash = "sha256-7jOOGiZmMXJTfIM2f6Do45/F9CiknrIgjUlXQAxxQZk=";
    };

    # PR Review — interactive Azure DevOps pull request review workflow.
    pr-review = aiLib.mkSkillFromFile ./pr-review/SKILL.md;
  };
}
