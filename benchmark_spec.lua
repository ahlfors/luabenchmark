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

    it('call bm to get a bm reporter', function()
        -- check the default label_width and format
        assert.are.same(bm.bm().label_width, bm.LABEL_WIDTH)
        assert.are.same(bm.bm().format, bm.FORMAT)

        assert.are.same(bm.bm(10).label_width, 10)
        local FORMAT = '%-2.3s %.3u %0.3t %r';
        assert.are.same(bm.bm(10, FORMAT).format, FORMAT)
        -- test no_gc
        bm.bm(bm.LABEL_WIDTH, bm.FORMAT, true)
    end)

    it('use Reporter to report', function()
        local reporter = bm.bm(bm.LABEL_WIDTH, '%-2.1s %.2u %.3t %r')
        reporter:report(function() end, 'test')
    end)

    it('bm should check the label_width can be an integer or not', function()
        assert.is_false(pcall(bm.bm, 3.76))
        assert.is_false(pcall(bm.bm, '3.76'))
        assert.is_true(pcall(bm.bm, 3.0))
        assert.is_true(pcall(bm.bm, '3'))
    end)
end)
