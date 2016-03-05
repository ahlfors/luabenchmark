local bm = require './benchmark'

local function take(secs)
  local t0 = os.clock()
  while os.difftime(os.clock() - t0) <= secs do end
end

describe('benchmark', function()
    it('Tms', function()
        local res = bm.Tms{stime=2.0}
        assert.are.same(res, bm.Tms{label='', stime=2.0, utime=0.0, total=2.0, real=0.0})
    end)
    it('measure', function()
        local time = 0.1
        local res = bm.measure(function()
            take(time)
        end, 'test')
        assert.are.same(res.label, 'test')
        assert.is_true(res.real > time)
        assert.is_true(res.total > time)
        assert.is_true(res.stime > 0)
        assert.is_true(res.utime > 0)
        assert.is_true(res.stime + res.utime == res.total)
    end)

    it('measure without label', function()
        local res = bm.measure(function()
        end)
        assert.are.same(res.label, '')
    end)

    it('realtime', function()
        local time = 0.1
        assert.is_true(bm.realtime(function()
            take(time)
        end) > time)
    end)
end)
