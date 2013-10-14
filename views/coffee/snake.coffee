# --                                                            ; {{{1
#
# File        : snake.coffee
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-10-14
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv3
#
# --                                                            ; }}}1

# TODO: tests, constants

U = this._        || require 'underscore'
B = this.bigbang  || require 'bigbang'
S = exports ? this.snake ||= {}

# --

S.mk_pit    = mk_pit    = (snake, goos) -> snake: snake, goos: goos
S.mk_snake  = mk_snake  = (dir, segs)   -> dir: dir, segs: segs
S.mk_goo    = mk_goo    = (loc, expire) -> loc: loc, expire: expire
S.mk_posn   = mk_posn   = (x, y)        -> x: x, y: y

# --

# FPS, SIZE, SEG_SIZE, MAX_GOO, EXPIRATION_TIME, WIDTH_PX, HEIGHT_PX,
# MT_SCENE, GOO_IMG, SEG_IMG, HEAD_IMG, HEAD_LEFT_IMG, HEAD_DOWN_IMG,
# HEAD_RIGHT_IMG, HEAD_UP_IMG, ENDGAME_TEXT_SIZE

# --

# TODO: FPS
S.start = start = (canvas = $('#canvas')[0]) ->
  w = mk_pit mk_snake('right', [mk_posn(1, 1)]),
    (fresh_goo() for i in [1..6])
  o =
    canvas: canvas, world: w, on_tick: next_pit,
    on_key: direct_snake, on_draw: render_pit, stop_when: is_dead,
    on_stop: render_end
  B o

S.next_pit = next_pit = (w) ->
  goo_to_eat = can_eat w.snake, w.goos
  if goo_to_eat
    mk_pit grow(w.snake), age_goo eat(w.goos, goo_to_eat)
  else
    mk_pit slither(w.snake), age_goo w.goos

S.direct_snake = direct_snake = (w, k) ->
  if is_dir k then world_change_dir w, k else w

S.render_pit = render_pit = (w) ->
  snake_and_scene w.snake, goo_list_and_scene(w.goos, MT_SCENE)

S.is_dead = is_dead = (w) ->
  is_self_colliding(w.snake) || is_wall_colliding(w.snake)

S.render_end = render_end = (w) ->
  t = B.text('Game over', ENDGAME_TEXT_SIZE, 'black')
  B.overlay t, render_pit(w)

# --

S.can_eat = can_eat = (sn, goos) ->
  U.find goos, (x) -> is_close(snake_head(sn), x)

S.eat = eat = (goos, goo) ->
  [fresh_goo()].concat U.without(goos, goo)

S.is_close = is_close = (seg, goo) -> U.isEqual seg, goo.loc

S.grow = grow = (sn) ->
  mk_snake sn.dir, [next_head(sn)].concat(sn.segs)

# --

S.slither = slither = (sn) ->
  mk_snake sn.dir, [next_head(sn)].concat(U.initial(sn.segs))

S.next_head = next_head = (sn) ->
  head = snake_head sn; dir = sn.dir
  switch
    when dir == 'up'    then posn_move head,  0, -1
    when dir == 'down'  then posn_move head,  0,  1
    when dir == 'left'  then posn_move head, -1,  0
    when dir == 'right' then posn_move head,  1,  0

S.posn_move = posn_move = (p, dx, dy) -> mk_posn p.x + dx, p.y + dy

# --

S.age_goo = age_goo = (goos) -> rot renew(goos)

S.renew = renew = (goos) ->
  U.map goos, (x) -> if is_rotten x then fresh_goo() else x

S.rot = rot = (goos) -> U.map goos, decay

S.is_rotten = is_rotten = (goo) -> goo.expire == 0

S.decay = decay = (goo) -> mk_goo goo.loc, goo.expire - 1

# TODO: check
S.fresh_goo = fresh_goo = () ->
  x = Math.random() * (SIZE - 1) + 1
  y = Math.random() * (SIZE - 1) + 1
  mk_goo mk_posn(x, y), EXPIRATION_TIME

# --

S.is_dir = is_dir = (x) ->
  x == 'up' || x == 'down' || x == 'left' || x == 'right'

S.world_change_dir = world_change_dir = (w, d) ->
  sn = w.snake
  if is_opposite_dir(sn.dir, d) && sn.segs.length > 1
    B.stop_with w
  else
    mk_pit snake_change_dir(sn, d), w.goos

S.is_opposite_dir = is_opposite_dir = (d1, d2) ->
  (d1 == 'up'     && d2 == 'down' ) ||
  (d1 == 'down'   && d2 == 'up'   ) ||
  (d1 == 'left'   && d2 == 'right') ||
  (d1 == 'right'  && d2 == 'left' )

# --

S.snake_and_scene = snake_and_scene = (sn, scene) ->
  sn_body_scene = img_list_and_scene(snake_body(sn), SEG_IMG, scene)
  img = switch sn.dir
    when 'up'     then HEAD_UP_IMG
    when 'down'   then HEAD_DOWN_IMG
    when 'left'   then HEAD_LEFT_IMG
    when 'right'  then HEAD_RIGHT_IMG
  img_and_scene snake_head(sn), img, sn_body_scene

S.goo_list_and_scene = goo_list_and_scene = (goos, scene) ->
  posns = U.map goos, (x) -> x.loc
  img_list_and_scene posns, GOO_IMG, scene

S.img_list_and_scene = img_list_and_scene = (posns, img, scene) ->
  f = (s, p) -> img_and_scene p, img, s
  U.reduce posns, f, scene

S.img_and_scene = img_and_scene = (posn, img, scene) ->
  B.place_image img, (posn.x * SEG_SIZE), (posn.y * SEG_SIZE), scene

# --

S.is_self_colliding = is_self_colliding = (sn) ->
  U.contains snake_body(sn), snake_head(sn)

S.is_wall_colliding = is_wall_colliding = (sn) ->
  x = snake_head(sn).x; y = snake_head(sn).y
  x == 0 || x == SIZE || y == 0 || y == SIZE

# --

S.snake_head = snake_head = (sn) -> U.first snake.segs
S.snake_body = snake_body = (sn) -> U.rest  snake.segs

S.snake_change_dir = snake_change_dir = (sn, d) ->
  mk_snake d, sn.segs

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
