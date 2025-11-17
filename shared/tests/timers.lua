local Framework = require("shared.framework")

require("shared.autoloader")

local function dummy() end
local function intervalDummy() end
local function threadDummy()
	return 1
end
local function tickDummy() end

local function test_is_valid()
	local handle = Timer.SetTimeout(dummy, 0.1)
	assert(Timer.IsValid(handle) == true, "Timer should be valid initially")
	Timer.ClearTimeout(handle)
end

local function test_invalidate()
	local handle = Timer.SetTimeout(dummy, 0.1)
	Timer.Invalidate(handle)
	assert(Timer.IsValid(handle) == false, "Timer should be invalid after Invalidate")
end

local function test_pause_resume()
	local handle = Timer.SetTimeout(dummy, 0.1)
	Timer.Resume(handle)
	assert(Timer.IsPaused(handle) == false, "Timer should not be paused after Resume")
	Timer.Pause(handle)
	assert(Timer.IsPaused(handle) == true, "Timer should be paused after Pause")
	Timer.Resume(handle)
	assert(Timer.IsPaused(handle) == false, "Timer should not be paused after Resume again")
	Timer.ClearTimeout(handle)
end

local function test_set_clear_timeout()
	local handle = Timer.SetTimeout(dummy, 0.1)
	assert(Timer.HasHandle(handle) == true, "Timer should have handle after SetTimeout")
	Timer.ClearTimeout(handle)
	assert(Timer.HasHandle(handle) == false, "Timer should not have handle after ClearTimeout")
end

local function test_set_clear_interval()
	local handle = Timer.SetInterval(intervalDummy, 0.1)
	assert(Timer.HasHandle(handle) == true, "Timer should have handle after SetInterval")
	Timer.ClearInterval(handle)
	assert(Timer.HasHandle(handle) == false, "Timer should not have handle after ClearInterval")
end

local function test_elapsed_time()
	local handle = Timer.SetTimeout(dummy, 0.1)
	assert(Timer.HasHandle(handle) == true, "Timer should have handle after SetTimeout")
	Timer.ResetElapsedTime(handle)
	local elapsed = Timer.GetElapsedTime(handle)
	assert(elapsed < 0.01, "Elapsed time should be near zero after ResetElapsedTime")
end

local function test_next_tick()
	Timer.SetNextTick(tickDummy)
end

local function test_get_remaining_time()
	local handle = Timer.SetTimeout(dummy, 0.2)
	local remaining = Timer.GetRemainingTime(handle)
	assert(remaining <= 0.2, "GetRemainingTime should be <= timeout")
	Timer.ClearTimeout(handle)
end

local function run_tests()
	test_is_valid()
	test_invalidate()
	test_pause_resume()
	test_set_clear_timeout()
	test_set_clear_interval()
	test_elapsed_time()
	test_next_tick()
	test_get_remaining_time()
	Framework.Debugging:Log("All Timer tests passed!")
end

if Framework.ShouldRunTests then
	do
		run_tests()
	end
end
