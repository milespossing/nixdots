# Patch neotest for Neovim 0.12 iter_matches breaking change.
# The {all = false} option was removed from Query:iter_matches;
# matches now always return tables of nodes instead of single nodes.
# See: https://github.com/nvim-neotest/neotest/pull/594
# TODO: Remove this overlay once the fix is merged upstream and in nixpkgs.
final: prev: {
  vimPlugins = prev.vimPlugins.extend (
    vfinal: vprev: {
      neotest = vprev.neotest.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.writeText "neotest-iter-matches.patch" ''
            --- a/lua/neotest/config/init.lua
            +++ b/lua/neotest/config/init.lua
            @@ -340,8 +340,9 @@
                       ]]
                     )
                     local symbols = {}
            -        for _, match, metadata in query:iter_matches(root, content, nil, nil, { all = false }) do
            -          for id, node in pairs(match) do
            +        for _, match, metadata in query:iter_matches(root, content, nil, nil) do
            +          for id, nodes in pairs(match) do
            +            local node = type(nodes) == "table" and nodes[#nodes] or nodes
                         local name = query.captures[id]
             
                         if name == "symbol" then
            --- a/lua/neotest/lib/treesitter/init.lua
            +++ b/lua/neotest/lib/treesitter/init.lua
            @@ -56,11 +56,12 @@
                   range = { root:range() },
                 },
               }
            -  for _, match, metadata in query:iter_matches(root, source, nil, nil, { all = false }) do
            +  for _, match, metadata in query:iter_matches(root, source, nil, nil) do
                 local captured_nodes = {}
                 local node_metadata = {}
                 for i, capture in ipairs(query.captures) do
            -      captured_nodes[capture] = match[i]
            +      local nodes = match[i]
            +      captured_nodes[capture] = type(nodes) == "table" and nodes[#nodes] or nodes
                   node_metadata[capture] = metadata[i]
                 end
                 local res = opts.build_position(file_path, source, captured_nodes, node_metadata)
          '')
        ];
      });
    }
  );
}
