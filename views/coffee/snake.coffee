$ ->
  anim  = window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame ||
          throw Error 'no *RequestAnimationFrame'

  mk_pit    = (snake, goos) -> snake: snake, goos: goos
  mk_snake  = (dir, segs)   -> dir: dir, segs: segs
  mk_posn   = (x, y)        -> x: x, y: y
  mk_goo    = (loc, expire) -> loc: loc, expire: expire

  # --

  fresh_goo = ->
    # ...

  close = (s, g) -> _.isEqual s, g.loc

  snake_head = (snake) -> _.first snake.segs

  can_eat = (snake, goos) ->
    _.find goos, (x) -> close(snake_head(snake), x)

  eat = (goos, goo) ->
    [fresh_goo()].concat _.without(goos, goo)

  age_goo = (goos) ->
    # ...

  posn_move = (p, dx, dy) -> mk_posn p.x + dx, p.y + dy

  next_head = (snake) ->
    head = snake_head snake; dir = snake.dir
    switch
      when dir == 'up'    then posn_move head,  0, -1
      when dir == 'down'  then posn_move head,  0,  1
      when dir == 'left'  then posn_move head, -1,  0
      when dir == 'right' then posn_move head,  1,  0

  grow = (snake) ->
    mk_snake snake.dir, [next_head(snake)].concat(snake.segs)

  slither = (snake) -> _.initial grow(snake)

  # --

  start = (canvas = $('#canvas')[0]) ->
    w = mk_pit mk_snake('right', [mk_posn(1, 1)]),
      (fresh_goo() for i in [1..6])
    bigbang
      canvas: canvas, world: w, on_tick: next_pit,
      on_key: direct_snake, on_draw: render_pit, stop_when: dead,
      on_stop: render_end

  next_pit = (w) ->
    snake = w.snake; goos = w.goos
    goo_to_eat = can_eat snake, goos
    if goo_to_eat
      mk_pit grow(snake), age_goo eat(goos, goo_to_eat)
    else
      mk_pit slither(snake), age_goo goos

  direct_snake = (w, k) ->
    # ...

  render_pit = (w) ->
    # ...

  dead = (w) ->
    # ...

  render_end = (w) ->
    # ...

  # --

  start()

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
