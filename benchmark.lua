local benchmarklib = require 'benchmarklib'
local cpu_clock = benchmarklib.cpu_clock
local wall_clock = benchmarklib.wall_clock
local difftime = os.difftime

local _M = {
    version = '0.1.0'
}

local default_tms = {
    label = '',
    stime = 0.0,
    utime = 0.0,
    real =  0.0
}
local mt = {}
mt.__index = default_tms

-- Create a Tms table.
-- Tms contains below fields:
-- * label, default ''
-- * stime system CPU time, default 0.0
-- * utime user CPU time, default 0.0
-- * real wall time, default 0.0
-- * total stime+utime
--
-- You can call like this: Tms{stime=2.0}
-- And it will return Tms{label='', stime=2.0, utime=0.0, total=2.0, real=0.0}
function _M.Tms(args)
    setmetatable(args, mt)
    args['total'] = args['stime'] + args['utime']
    return args
end

-- Returns the time used to execute the given function as a Tms table.
function _M.measure(func, label)
    local real0 = wall_clock()
    local stime0, utime0 = cpu_clock()
    func()
    local stime1, utime1 = cpu_clock()
    return _M.Tms{label=label,
               real=wall_clock()-real0,
               stime=stime1-stime0,
               utime=utime1-utime0
           }
end

-- Returns the elapsed real time used to execute the given function
function _M.realtime(func)
    local t0 = wall_clock()
    func()
    return wall_clock() - t0
end

return _M
