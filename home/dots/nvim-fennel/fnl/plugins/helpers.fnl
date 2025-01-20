(fn setup [name ...]
  ((. (require name) :setup) ...))

{ :setup setup }
