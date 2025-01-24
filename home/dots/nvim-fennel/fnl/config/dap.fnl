(lambda [] 
  (local dap (require :dap))
  (set dap.adapters.chrome {
       :type "executable"
       }))
