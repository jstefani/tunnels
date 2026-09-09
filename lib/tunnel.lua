-- softcut experiments

local tn = {}

local VOICE_PARAM_COUNT = 19

local function add_cs(id, name, spec, fn, hide)
  params:add{
    type = "control",
    id = id,
    name = name,
    controlspec = spec,
    action = fn
  }
  if hide then params:hide(id) end
end

function tn.init()
  print("entering tunnels")

  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  softcut.level_cut_cut(1, 2, 0.18)
  softcut.level_cut_cut(3, 4, 0.18)
  softcut.level_cut_cut(4, 1, 0.15)
  softcut.level_cut_cut(3, 2, 0.15)

  for i = 1, 4 do
    softcut.level_input_cut(i, 1, 1.0)
    softcut.level_input_cut(i, 2, 0.0)
    softcut.buffer(i, 1)
    softcut.play(i, 1)
    softcut.loop(i, 1)
    softcut.rec(i, 1)
    softcut.rec_level(i, 1)
    softcut.enable(i, 1)
  end

  for i = 1, 4 do
    params:add_group("tn_voice_"..i, "voice "..i, VOICE_PARAM_COUNT)

    add_cs("delay_rate"..i, "rate",
      controlspec.new(-8, 8, "lin", 0, 1, ""),
      function(x) softcut.rate(i, x) end)

    add_cs("delay_feedback"..i, "feedback",
      controlspec.new(0, 1, "lin", 0, 0.70, ""),
      function(x) softcut.pre_level(i, x) end)

    add_cs("fade_time"..i, "fade",
      controlspec.new(0, 5, "lin", 0, 0.2, ""),
      function(x) softcut.fade_time(i, x) end)

    add_cs("filter_fc"..i, "filter cutoff",
      controlspec.new(10, 12000, "exp", 1, 1200, "Hz"),
      function(x) softcut.filter_fc(i, x) end)

    add_cs("delay_level"..i, "level",
      controlspec.new(0, 1, "lin", 0, 0, ""),
      function(x) softcut.level(i, x) end)

    add_cs("delay_pan"..i, "pan",
      controlspec.new(-1, 1, "lin", 0, 0, ""),
      function(x) softcut.pan(i, x) end)

    add_cs("delay_loop_start"..i, "loop start",
      controlspec.new(0, 30, "lin", 0, 0, "s"),
      function(x) softcut.loop_start(i, x) end)

    add_cs("delay_loop_end"..i, "loop end",
      controlspec.new(0.01, 30, "lin", 0, i + 1, "s"),
      function(x) softcut.loop_end(i, x) end)

    add_cs("delay_position"..i, "position",
      controlspec.new(0, 30, "lin", 0, 0, "s"),
      function(x) softcut.position(i, x) end, true)

    add_cs("delay_rec_offset"..i, "rec offset",
      controlspec.new(-100, 100, "lin", 0, -0.00015, ""),
      function(x) softcut.rec_offset(i, x) end, true)

    add_cs("delay_filter_dry"..i, "filter dry",
      controlspec.new(0, 1, "lin", 0, 0.125, ""),
      function(x) softcut.filter_dry(i, x) end, true)

    add_cs("delay_filter_lp"..i, "filter lp",
      controlspec.new(0, 1, "lin", 0, 0, ""),
      function(x) softcut.filter_lp(i, x) end, true)

    add_cs("delay_filter_bp"..i, "filter bp",
      controlspec.new(0, 1, "lin", 0, 1, ""),
      function(x) softcut.filter_bp(i, x) end, true)

    add_cs("delay_filter_rq"..i, "filter rq",
      controlspec.new(0.1, 10, "lin", 0, 2, ""),
      function(x) softcut.filter_rq(i, x) end, true)

    add_cs("delay_filter_fc_mod"..i, "filter fc mod",
      controlspec.new(0, 1, "lin", 0, 0, ""),
      function(x) softcut.filter_fc_mod(i, x) end, true)

    add_cs("delay_level_slew"..i, "level slew",
      controlspec.new(0, 8, "lin", 0, 0.001, "s"),
      function(x) softcut.level_slew_time(i, x) end, true)

    add_cs("delay_rate_slew"..i, "rate slew",
      controlspec.new(0, 8, "lin", 0, 0.001, "s"),
      function(x) softcut.rate_slew_time(i, x) end, true)

    add_cs("delay_phase_quant"..i, "phase quant",
      controlspec.new(0, 8, "lin", 0, 1, ""),
      function(x) softcut.phase_quant(i, x) end, true)

    add_cs("delay_phase_offset"..i, "phase offset",
      controlspec.new(-8, 8, "lin", 0, 0, ""),
      function(x) softcut.phase_offset(i, x) end, true)
  end
end

function tn.reset()
  for i = 1, 4 do
    params:set("delay_level"..i, 1)
    params:set("delay_loop_start"..i, 0)
    params:set("delay_loop_end"..i, i + 1)
    params:set("delay_position"..i, 0)
    params:set("delay_rec_offset"..i, -0.00015)
    params:set("delay_filter_dry"..i, 0.5)
    params:set("delay_filter_lp"..i, 0)
    params:set("delay_filter_bp"..i, 1.0)
    params:set("delay_filter_rq"..i, 2.0)
    params:set("delay_filter_fc_mod"..i, 0)
    params:set("delay_level_slew"..i, 0.001)
    params:set("delay_rate_slew"..i, 0.001)
    params:set("delay_phase_quant"..i, 1)
    params:set("delay_phase_offset"..i, 0)
  end
  params:set("filter_fc3", math.random(40, 150))
  params:set("filter_fc4", math.random(150, 300))
  params:set("filter_fc2", math.random(300, 1000))
  params:set("filter_fc1", math.random(1000, 1800))
end

function tn.pan(tunnelgroup)
  if tunnelgroup == 1 then
    params:set("delay_pan1", math.random(50, 90) * -0.01)
    params:set("delay_pan4", math.random(10, 45) * 0.01)
  elseif tunnelgroup == 2 then
    params:set("delay_pan2", math.random(50, 90) * 0.01)
    params:set("delay_pan3", math.random(10, 45) * -0.01)
  end
end

function tn.randomize(mode, tunnelgroup)
  tn.pan(tunnelgroup)
  tn.reset()

  -- off
  if mode == 1 then
    for i = 1, 4 do
      params:set("delay_level"..i, 0)
    end

  -- fractal landscape
  elseif mode == 2 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(0, 250) * 0.01)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_loop_end"..i, math.random(50, 500) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 90) * 0.01)
        params:set("filter_fc"..i, math.random(40, 1500))
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(0, 250) * 0.01)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_loop_end"..i, math.random(50, 500) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 90) * 0.01)
        params:set("filter_fc"..i, math.random(40, 1500))
      end
    end

  -- disemboguement
  elseif mode == 3 then
    if tunnelgroup == 1 then
      params:set("filter_fc1", math.random(40, 400))
      params:set("filter_fc2", math.random(400, 800))
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(1, 10) * 0.1)
        params:set("fade_time"..i, math.random(0, 20) * 0.1)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 80) * 0.01)
        params:set("delay_loop_end"..i, math.random(5, 30) * 0.01)
      end
    elseif tunnelgroup == 2 then
      params:set("filter_fc3", math.random(40, 400))
      params:set("filter_fc4", math.random(400, 800))
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(-10, -1) * 0.1)
        params:set("fade_time"..i, math.random(0, 20) * 0.1)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 80) * 0.01)
        params:set("delay_loop_end"..i, math.random(30, 50) * 0.01)
      end
    end

  -- post-horizon
  elseif mode == 4 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(1, 10) * 0.1)
        params:set("fade_time"..i, math.random(50, 100) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_loop_end"..i, math.random(100, 1000) * 0.01)
        params:set("delay_feedback"..i, math.random(10, 80) * 0.01)
        params:set("delay_filter_bp"..i, math.random(0, 100) * 0.01)
        params:set("filter_fc"..i, math.random(400, 2000))
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(-10, -1) * 0.1)
        params:set("fade_time"..i, math.random(50, 100) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_loop_end"..i, math.random(100, 1000) * 0.01)
        params:set("delay_feedback"..i, math.random(10, 80) * 0.01)
        params:set("delay_filter_bp"..i, math.random(0, 100) * 0.01)
        params:set("filter_fc"..i, math.random(400, 2000))
      end
    end

  -- coded air
  elseif mode == 5 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_feedback"..i, math.random(50, 75) * 0.01)
        params:set("delay_rate"..i, math.random(-100, 0) * 0.02)
        params:set("delay_loop_end"..i, math.random(10, 500) * 0.01)
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_feedback"..i, math.random(0, 50) * 0.01)
        params:set("delay_rate"..i, math.random(-100, 0) * 0.02)
        params:set("delay_loop_end"..i, math.random(10, 500) * 0.01)
      end
    end

  -- failing lantern
  elseif mode == 6 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(10, 25) * 0.1)
        params:set("delay_loop_end"..i, math.random(6, 10))
        params:set("delay_feedback"..i, math.random(10, 30) * 0.01)
        params:set("fade_time"..i, math.random(0, 40) * 0.1)
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(10, 25) * 0.1)
        params:set("delay_loop_end"..i, math.random(4, 6))
        params:set("delay_feedback"..i, math.random(10, 30) * 0.01)
        params:set("fade_time"..i, math.random(0, 40) * 0.1)
      end
    end

  -- blue cat
  elseif mode == 7 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(0, 80) * 0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(0, 100) * 0.01)
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(0, 80) * 0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(0, 100) * 0.01)
      end
    end

  -- crawler
  elseif mode == 8 then
    params:set("delay_loop_end1", 0.1)
    params:set("delay_loop_end2", 0.4)
    params:set("delay_loop_end3", 0.2)
    params:set("delay_loop_end4", 0.3)
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(5, 15) * 0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_feedback"..i, math.random(0, 100) * 0.01)
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(5, 15) * 0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_feedback"..i, math.random(0, 100) * 0.01)
      end
    end

  -- hanging mosses
  elseif mode == 9 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_loop_start"..i, math.random(0, 1) * 0.1)
        params:set("delay_loop_end"..i, math.random(1, 10))
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_rec_offset"..i, math.random(0, 1000) * 0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_feedback"..i, math.random(5, 25) * 0.01)
        params:set("delay_rate_slew"..i, math.random(0, 80) * 0.1)
        params:set("delay_phase_quant"..i, math.random(0, 80) * 0.1)
        params:set("filter_fc"..i, math.random(100, 1000))
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_loop_start"..i, math.random(0, 1) * 0.1)
        params:set("delay_loop_end"..i, math.random(1, 10))
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_rec_offset"..i, math.random(0, 1000) * -0.1)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_feedback"..i, math.random(5, 25) * 0.01)
        params:set("delay_rate_slew"..i, math.random(0, 80) * 0.1)
        params:set("delay_phase_quant"..i, math.random(0, 80) * 0.1)
        params:set("filter_fc"..i, math.random(100, 1000))
      end
    end

  -- rate filter
  elseif mode == 10 then
    if tunnelgroup == 1 then
      for i = 1, 2 do
        params:set("delay_rate"..i, math.random(0, 250) * 0.01)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_loop_end"..i, math.random(50, 500) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 90) * 0.01)
        params:set("filter_fc"..i, math.random(40, 1500) * params:get("delay_rate"..i))
        params:set("delay_filter_dry"..i, 0.1)
        params:set("delay_filter_fc_mod"..i, 0.5)
      end
    elseif tunnelgroup == 2 then
      for i = 3, 4 do
        params:set("delay_rate"..i, math.random(0, 250) * 0.01)
        params:set("fade_time"..i, math.random(0, 6) * 0.1)
        params:set("delay_loop_end"..i, math.random(50, 500) * 0.01)
        params:set("delay_position"..i, math.random(0, 10) * 0.1)
        params:set("delay_feedback"..i, math.random(10, 90) * 0.01)
        params:set("filter_fc"..i, math.random(40, 1500) * params:get("delay_rate"..i))
        params:set("delay_filter_dry"..i, 0.1)
        params:set("delay_filter_fc_mod"..i, 0.5)
      end
    end
  end
end

return tn
