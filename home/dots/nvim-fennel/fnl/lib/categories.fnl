(local monoid {})

(fn monoid.new [c i]
  {:concat c :identity i})

(local semigroup {})

(fn semigroup.new [f]
  {:concat f})

{: monoid : semigroup}
