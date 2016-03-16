local bm = require './benchmark'

local ary = {}
for i = 1, 1e7 do
    ary[i] = 0
end

-- range vs ipairs vs pairs
-- use default FORMAT and stop GC
local reporter = bm.bm(10, bm.FORMAT, true) -- 10 is enough for the longest label
reporter:report(function()
    for i = 1, #ary do
        ary[i] = i
    end
end, 'for range')

reporter:report(function()
    for i, v in ipairs(ary) do
        ary[i] = i
    end
end, 'for ipairs')

reporter:report(function()
    for k, v in pairs(ary) do
        ary[k] = i
    end
end, 'for pairs')

-- table.insert vs set with index
ary = {}
-- specify format
-- %s -> system
-- %u -> user
-- %t -> total
-- %r -> real
reporter = bm.bm(bm.LABEL_WIDTH, 'user: %u\tsystem: %s\ttotal: %t\treal: %r')
reporter:report(function()
    for i = 1, 1e6 do
        table.insert(ary, i)
    end
end)
ary = {}
reporter:report(function()
    for i = 1, 1e6 do
        ary[i] = i
    end
end)

-- which is faster,
reporter = bm.bm(30)
reporter:report(function()
    local size = #ary
    for i = 1, size do
        ary[i] = 0
    end
end, 'count up the size first')

reporter:report(function()
    for i = 1, #ary do
        ary[i] = 0
    end
end, 'or count it in loop?')

-- other API
-- measure the CPU time(in user space or system space) and Wall time
print(bm.measure(function()
    table.sort(ary)
end))
-- or just the Wall time
print(bm.realtime(function()
    table.sort(ary)
end))
