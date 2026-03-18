# Builder functions for AI agent skills and MCP servers.
# Imported by default.nix and exposed via _module.args.aiLib.
{ lib, pkgs }:
{
  # Build an inline skill from structured fields.
  # Returns an attrset matching skillType (with source = null).
  mkSkill =
    {
      description,
      content,
      license ? null,
      compatibility ? null,
      metadata ? { },
    }:
    {
      inherit
        description
        content
        license
        compatibility
        metadata
        ;
      source = null;
    };

  # Build a skill from a local file path.
  # The file must be a complete SKILL.md (frontmatter + body).
  mkSkillFromFile = path: {
    description = "";
    content = "";
    license = null;
    compatibility = null;
    metadata = { };
    source = path;
  };

  # Fetch a skill from a GitHub repository (full repo archive).
  # The file at `path` must be a complete SKILL.md (frontmatter + body).
  fetchSkillFromGitHub =
    {
      owner,
      repo,
      rev,
      path,
      hash,
    }:
    {
      description = "";
      content = "";
      license = null;
      compatibility = null;
      metadata = { };
      source = "${
        pkgs.fetchFromGitHub {
          inherit
            owner
            repo
            rev
            hash
            ;
        }
      }/${path}";
    };

  # Fetch a single SKILL.md from a GitHub repository (raw file only).
  # Lighter than fetchSkillFromGitHub — avoids downloading the full repo.
  fetchSkillFromGitHubFile =
    {
      owner,
      repo,
      rev,
      path,
      hash,
    }:
    {
      description = "";
      content = "";
      license = null;
      compatibility = null;
      metadata = { };
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${path}";
        inherit hash;
      };
    };

  # Build a local (stdio) MCP server definition.
  mkLocalMcp =
    {
      command,
      package ? null,
      environment ? { },
      enabled ? true,
    }:
    {
      type = "local";
      inherit
        command
        environment
        enabled
        package
        ;
      url = null;
      headers = { };
    };

  # Build a remote (SSE/streamable-HTTP) MCP server definition.
  mkRemoteMcp =
    {
      url,
      headers ? { },
      enabled ? true,
    }:
    {
      type = "remote";
      inherit url headers enabled;
      command = [ ];
      environment = { };
      package = null;
    };
}
