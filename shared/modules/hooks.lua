-- Testing https://github.com/Srlion/Hook-Library :D

local Framework = require("shared.framework")
local math = math
local table = table
local pairs = pairs
local setmetatable = setmetatable
local function isstring(v)
	return type(v) == "string"
end
local function isnumber(v)
	return type(v) == "number"
end
local function isbool(v)
	return type(v) == "boolean"
end
local function isfunction(v)
	return type(v) == "function"
end
local function ErrorNoHaltWithStack(msg)
	error(debug.traceback(msg))
end

local type = type
local print = function(...)
	Framework.Debugging.Log(...)
end
local GProtectedCall = pcall
local tostring = tostring
local error = error
local Hook = {}

local EMPTY_FUNC = function() end

-- this is for addons that think every server only has ulx and supplies numbers for priorities instead of using the constants
HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

PRE_HOOK = { -4 }
PRE_HOOK_RETURN = { -3 }
NORMAL_HOOK = { 0 }
POST_HOOK_RETURN = { 3 }
POST_HOOK = { 4 }

local PRE_HOOK = PRE_HOOK
local PRE_HOOK_RETURN = PRE_HOOK_RETURN
local NORMAL_HOOK = NORMAL_HOOK
local POST_HOOK_RETURN = POST_HOOK_RETURN
local POST_HOOK = POST_HOOK

local NORMAL_PRIORITIES_ORDER = {
	[PRE_HOOK] = 1,
	[HOOK_MONITOR_HIGH] = 2,
	[PRE_HOOK_RETURN] = 3,
	[HOOK_HIGH] = 4,
	[NORMAL_HOOK] = 5,
	[HOOK_NORMAL] = 5,
	[HOOK_LOW] = 6,
	[HOOK_MONITOR_LOW] = 7,
	-- Special hooks, they don't use an order
}

local EVENTS_LISTS = {
	-- Special hooks
	[POST_HOOK_RETURN] = 2,
	[POST_HOOK] = 3,
}
for k, v in pairs(NORMAL_PRIORITIES_ORDER) do
	EVENTS_LISTS[k] = 1
end

local MAIN_PRIORITIES = { [PRE_HOOK] = true, [PRE_HOOK_RETURN] = true, [NORMAL_HOOK] = true, [POST_HOOK_RETURN] = true, [POST_HOOK] = true }

local PRIORITIES_NAMES = {
	[PRE_HOOK] = "PRE_HOOK",
	[HOOK_MONITOR_HIGH] = "HOOK_MONITOR_HIGH",
	[PRE_HOOK_RETURN] = "PRE_HOOK_RETURN",
	[HOOK_HIGH] = "HOOK_HIGH",
	[NORMAL_HOOK] = "NORMAL_HOOK",
	[HOOK_NORMAL] = "HOOK_NORMAL",
	[HOOK_LOW] = "HOOK_LOW",
	[HOOK_MONITOR_LOW] = "HOOK_MONITOR_LOW",
	[POST_HOOK_RETURN] = "POST_HOOK_RETURN",
	[POST_HOOK] = "POST_HOOK",
}

Author = "Srlion"
Version = "3.0.0"

local events = {}

local node_meta = {
	-- will only be called to retrieve the function
	__index = function(node, key)
		if key ~= 0 then -- this should never happen
			error("attempt to index a node with a key that is not 0: " .. tostring(key))
		end
		-- we need to check if the hook is still valid, if priority changed OR if the hook was removed from the list, we check from events table
		local event = node.event
		local hook_table = event[node.name]
		if not hook_table then
			return EMPTY_FUNC
		end -- the hook was removed

		if hook_table.priority ~= node.priority then
			return EMPTY_FUNC
		end

		return hook_table.func -- return the new/up-to-date function
	end,
}
local function CopyPriorityList(self, priority)
	local old_list = self[EVENTS_LISTS[priority]]
	local new_list = {}
	do
		local j = 0
		for i = 1, old_list[
			0 --[[length]]
		] do
			local node = old_list[i]
			if not node.removed then -- don't copy removed hooks
				j = j + 1
				local new_node = {
					[0 --[[func]]] = node[
						0 --[[func]]
					],
					event = node.event,
					name = node.name,
					priority = node.priority,
					idx = j,
				}
				new_list[j] = new_node
				-- we need to update the node reference in the event table
				local hook_table = node.event[node.name]
				hook_table.node = new_node
			end
			-- we need to delete the function reference so __index can work properly
			-- we do it to all nodes because they can't be updated when hooks are added/removed, so they need to be able to check using __index
			node[
				0 --[[func]]
			] = nil
			setmetatable(node, node_meta)
		end
		new_list[
			0 --[[length]]
		] = j -- update the length
	end
	local list_index = EVENTS_LISTS[priority] -- 1 for normal hooks, 2 for post return hooks, 3 for post hooks
	self[list_index] = new_list
end

local function new_event(name)
	if not events[name] then
		local function GetPriorityList(self, priority)
			return self[EVENTS_LISTS[priority]]
		end

		-- [0] = list length
		local lists = {
			[1] = { [0] = 0 }, -- normal hooks
			[2] = { [0] = 0 }, -- post return hooks
			[3] = { [0] = 0 }, -- post hooks

			CopyPriorityList = CopyPriorityList,
			GetPriorityList = GetPriorityList,
		}

		-- create the event table, we use [0] as hook names can't be numbers
		events[name] = { [0] = lists }
	end
	return events[name]
end

function Hook.GetTable()
	local new_table = {}
	for event_name, event in pairs(events) do
		local hooks = {}
		for i = 1, 3 do
			local list = event[0][i]
			for j = 1, list[
				0 --[[length]]
			] do
				local node = list[j]
				hooks[node.name] = event[node.name].real_func
			end
		end
		new_table[event_name] = hooks
	end
	return new_table
end

function Hook.Remove(event_name, name)
	if not isstring(event_name) then
		ErrorNoHaltWithStack("bad argument #1 to 'Remove' (string expected, got " .. type(event_name) .. ")")
		return
	end

	local notValid = isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid
	if not isstring(name) and notValid then
		ErrorNoHaltWithStack("bad argument #2 to 'Remove' (string expected, got " .. type(name) .. ")")
		return
	end

	local event = events[event_name]
	if not event then
		return
	end -- no event with that name

	local hook_table = event[name]
	if not hook_table then
		return
	end -- no hook with that name

	hook_table.node.removed = true

	-- we need to overwrite the priority list with the new one, to make sure we don't mess up with ongoing iterations inside hook.Call/ProtectedCall
	-- we basically copy the list without the removed hook
	event[
		0 --[[lists]]
	]:CopyPriorityList(hook_table.priority)

	event[name] = nil -- remove the hook from the event table
end

function Hook.Add(event_name, name, func, priority)
	if not isstring(event_name) then
		ErrorNoHaltWithStack("bad argument #1 to 'Add' (string expected, got " .. type(event_name) .. ")")
		return
	end
	if not isfunction(func) then
		ErrorNoHaltWithStack("bad argument #3 to 'Add' (function expected, got " .. type(func) .. ")")
		return
	end

	local notValid = name == nil or isnumber(name) or isbool(name) or isfunction(name) or not name.IsValid
	if not isstring(name) and notValid then
		ErrorNoHaltWithStack("bad argument #2 to 'Add' (string expected, got " .. type(name) .. ")")
		return
	end

	local real_func = func
	if not isstring(name) then
		func = function(...)
			local isvalid = name.IsValid
			if isvalid and isvalid(name) then
				return real_func(name, ...)
			end
			Hook.Remove(event_name, name)
		end
	end

	if isnumber(priority) then
		priority = math.floor(priority)
		if priority < -2 then
			priority = -2
		end
		if priority > 2 then
			priority = 2
		end
		if priority == -2 or priority == 2 then -- ulx doesn't allow returning anything in monitor hooks
			local old_func = func
			func = function(...)
				old_func(...)
			end
		end
	elseif MAIN_PRIORITIES[priority] then
		if priority == PRE_HOOK then
			local old_func = func
			func = function(...) -- this is done to stop the function from returning anything
				old_func(...)
			end
		end
		priority = priority
	else
		if priority ~= nil then
			ErrorNoHaltWithStack("bad argument #4 to 'Add' (priority expected, got " .. type(priority) .. ")")
		end
		-- we probably don't want to stop the function here because it's not a critical error
		priority = NORMAL_HOOK
	end

	local event = new_event(event_name)

	-- check if the hook already exists
	do
		local hook_info = event[name]
		if hook_info then
			-- check if priority is different, if not then we just update the function
			if hook_info.priority == priority then
				hook_info.func = func
				hook_info.real_func = real_func
				hook_info.node[
					0 --[[func]]
				] = func -- update the function in the node
				return
			end
			-- if priority is different then we consider it a new hook
			Hook.Remove(event_name, name)
		else
			-- create a new hook list to use, we need to shadow the old one
			event[0]:CopyPriorityList(priority)
		end
	end

	local hook_list = event[0]:GetPriorityList(priority)

	local hk_n = hook_list[
		0 --[[length]]
	] + 1
	local node = {
		[0 --[[func]]] = func,
		event = event,
		name = name,
		priority = priority,
		idx = hk_n, -- this is used to keep order of the hooks based on when they were added, to have a consistent order
	}
	hook_list[hk_n] = node
	hook_list[
		0 --[[length]]
	] = hk_n

	event[name] = {
		name = name,
		priority = priority,
		func = func,
		real_func = real_func,
		node = node,
	}

	if NORMAL_PRIORITIES_ORDER[priority] then
		table.sort(hook_list, function(a, b)
			local a_order = NORMAL_PRIORITIES_ORDER[a.priority]
			local b_order = NORMAL_PRIORITIES_ORDER[b.priority]
			if a_order == b_order then
				return a.idx < b.idx
			end
			return a_order < b_order
		end)
	end
end

function Hook.Run(name, ...)
	return Hook.Call(name, nil, ...)
end

function Hook.ProtectedRun(name, ...)
	return Hook.ProtectedCall(name, nil, ...)
end

function Hook.Call(event_name, gm, ...)
	local event = events[event_name]
	if not event then -- fast path
		if not gm then
			return
		end
		local gm_func = gm[event_name]
		if not gm_func then
			return
		end
		return gm_func(gm, ...)
	end

	local lists = event[
		0 --[[lists]]
	]

	local hook_name, a, b, c, d, e, f

	do -- normal hooks
		local normal_hooks = lists[1]
		for i = 1, normal_hooks[
			0 --[[length]]
		] do
			local node = normal_hooks[i]
			local n_a, n_b, n_c, n_d, n_e, n_f = node[
				0 --[[func]]
			](...)
			if n_a ~= nil then
				hook_name, a, b, c, d, e, f = node.name, n_a, n_b, n_c, n_d, n_e, n_f
				break
			end
		end
	end

	if not hook_name and gm then
		local gm_func = gm[event_name]
		if gm_func then
			hook_name, a, b, c, d, e, f = gm, gm_func(gm, ...)
		end
	end

	-- we need to check if there is any post(return) hooks, if not then we can return early
	if
		lists[2][
			0 --[[length]]
		] == 0 and lists[3][
			0 --[[length]]
		] == 0
	then
		return a, b, c, d, e, f
	end

	local returned_values = { hook_name, a, b, c, d, e, f }

	do -- post return hooks
		local post_return_hooks = lists[2]
		for i = 1, post_return_hooks[
			0 --[[length]]
		] do
			local node = post_return_hooks[i]
			local n_a, n_b, n_c, n_d, n_e, n_f = node[
				0 --[[func]]
			](returned_values, ...)
			if n_a ~= nil then
				a, b, c, d, e, f = n_a, n_b, n_c, n_d, n_e, n_f
				returned_values = { node.name, a, b, c, d, e, f }
				break
			end
		end
	end

	do -- post hooks
		local post_hooks = lists[3]
		for i = 1, post_hooks[
			0 --[[length]]
		] do
			local node = post_hooks[i]
			node[
				0 --[[func]]
			](returned_values, ...)
		end
	end

	return a, b, c, d, e, f
end

function Hook.ProtectedCall(event_name, gm, ...)
	local event = events[event_name]
	if not event then -- fast path
		if not gm then
			return
		end
		local gm_func = gm[event_name]
		if not gm_func then
			return
		end
		GProtectedCall(gm_func, gm, ...)
		return
	end

	local lists = event[
		0 --[[lists]]
	]

	do
		local normal_hooks = lists[1]
		for i = 1, normal_hooks[
			0 --[[length]]
		] do
			local node = normal_hooks[i]
			GProtectedCall(
				node[
					0 --[[func]]
				],
				...
			)
		end
	end

	if gm then
		local gm_func = gm[event_name]
		if gm_func then
			GProtectedCall(gm_func, gm, ...)
		end
	end

	local returned_values = { nil, nil, nil, nil, nil, nil, nil }

	do
		local post_return_hooks = lists[2]
		for i = 1, post_return_hooks[
			0 --[[length]]
		] do
			local node = post_return_hooks[i]
			GProtectedCall(
				node[
					0 --[[func]]
				],
				returned_values,
				...
			)
		end
	end

	do
		local post_hooks = lists[3]
		for i = 1, post_hooks[
			0 --[[length]]
		] do
			local node = post_hooks[i]
			GProtectedCall(
				node[
					0 --[[func]]
				],
				returned_values,
				...
			)
		end
	end
end

function Hook.Debug(event_name)
	local event = events[event_name]
	if not event then
		print("No event with that name")
		return
	end

	local lists = event[0]
	print("------START------")
	print("event:", event_name)
	for i = 1, 3 do
		local list = lists[i]
		for j = 1, list[
			0 --[[length]]
		] do
			local node = list[j]
			print("----------")
			print("   name:", node.name)
			print("   func:", node[0])
			print("   real_func:", event[node.name].real_func)
			print("   priority:", PRIORITIES_NAMES[node.priority])
			print("   idx:", node.idx)
		end
	end
	print("-------END-------")
end

-- tests
-- lots of testing cases are taken from meepen https://github.com/meepen/gmod-hooks-revamped/blob/master/hooksuite.lua
-- big thanks to him really for his great work
-- (when i was making the library i was testing lots of random cases and i never noted them down, there were lots of shady cases but unfortunately they are gone)
-- Add it to the bottom of hook.lua file and then run hook.Test() in console to run the tests

local assert = function(istrue, ...)
	if not istrue then
		error("hook.Test failed! " .. tostring(...))
	end
end
local insert = table.insert
local pcall = pcall
local Call, Run, Add, Remove = Hook.Call, Hook.Run, Hook.Add, Hook.Remove

local TEST = {}

-- this is to check if hooks order is by first to last or last to first

setmetatable(TEST, {
	__call = function(self, func)
		insert(self, func)
	end,
})

-- Basic add and call test
TEST(function(name)
	local gm_table = {}
	gm_table[name] = function(gm, ret)
		return ret
	end

	local ran = false
	Add(name, "1", function()
		ran = true
	end)

	local ret = Call(name, gm_table, 1)

	assert(ran == true, "hook.Call didn't run the hook")
	assert(ret == 1, "hook.Call didn't run the gamemode function or returned the wrong value")
end)

-- Adding hooks with same priority
TEST(function(name)
	local order = {}
	for i = 1, 3 do
		Add(name, tostring(i), function()
			table.insert(order, tostring(i))
		end, NORMAL_PRIORITY)
	end

	Call(name, {})

	assert(table.concat(order) == "123", "Hooks with the same priority did not execute in order of addition")
end)

local function table_has_value(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

-- Remove hook test
TEST(function(name)
	local executed = {}
	Add(name, "hook1", function()
		table.insert(executed, "hook1")
	end)
	Add(name, "hook2", function()
		table.insert(executed, "hook2")
	end)

	Remove(name, "hook1")
	Call(name, {})

	assert(not table_has_value(executed, "hook1"), "Removed hook should not execute")
end)

-- Replace hook functionality
TEST(function(name)
	local executed = false
	Add(name, "hook", function()
		executed = true
	end)
	Add(name, "hook", function()
		executed = false
	end)

	Call(name, {})

	assert(executed == false, "Hook should have its functionality replaced")
end)

-- Chain of hooks
TEST(function(name)
	local order = {}
	for i = 1, 5 do
		Add(name, "hook" .. tostring(i), function()
			table.insert(order, "hook" .. tostring(i))
		end)
	end

	Call(name, {})

	assert(table.concat(order) == "hook1hook2hook3hook4hook5", "Complex chain of hooks did not execute correctly")
end)

-- Concurrent add/remove during call
TEST(function(name)
	local dynamic_hook = function()
		Remove(name, "dynamic")
	end
	Add(name, "static", function()
		Add(name, "dynamic", dynamic_hook)
	end)

	Call(name, {})

	assert(pcall(Call, name, {}), "Should be stable after concurrent add/remove during call")
end)

-- Nested hok calls
TEST(function(name)
	local nested_called = false
	Add(name, "outer", function()
		Call("nested", {})
	end)
	Add("nested", "inner", function()
		nested_called = true
	end)

	Call(name, {})

	assert(nested_called, "Nested hook calls should be handled correctly")
end)

-- Hooks with variable arguments
TEST(function(name)
	local args_received = false
	Add(name, "varargs", function(...)
		args_received = { ... }
	end)

	Call(name, {}, 1, 2, 3)

	assert(#args_received == 3 and args_received[1] == 1 and args_received[2] == 2 and args_received[3] == 3, "Hooks should handle variable arguments correctly")
end)

-- Hook call with gamemode function and no hooks
TEST(function(name)
	local gm_table = {}
	gm_table[name] = function()
		return "gm_called"
	end

	local ret = Call(name, gm_table)

	assert(ret == "gm_called", "The gamemode function should run and return its value when no hooks are present")
end)

-- PreHook with return stopping execution
TEST(function(name)
	local gm_table = {}
	gm_table[name] = function()
		return "gm_not_called"
	end
	local returnValue = nil
	Add(name, "PreHookReturn", function()
		return "pre_returned"
	end, PRE_HOOK_RETURN)

	returnValue = Call(name, gm_table)

	assert(returnValue == "pre_returned", "Pre-hook with return should stop execution and return its value")
end)

-- Normal hook running with PostHook present
TEST(function(name)
	local normal_hook_ran = false
	local post_hood_ran = false
	Add(name, "normalhook", function()
		normal_hook_ran = true
	end, NORMAL_HOOK)
	Add(name, "posthook", function()
		post_hood_ran = true
	end, POST_HOOK)

	Call(name, {})

	assert(normal_hook_ran and post_hood_ran, "Both normal and posthooks should run")
end)

-- Post-Hook with return modifying overall return value
TEST(function(name)
	local return_value = nil
	Add(name, "normalhook", function()
		return "original_return"
	end, NORMAL_HOOK)
	Add(name, "posthookreturn", function()
		return "post_modified"
	end, POST_HOOK_RETURN)

	return_value = Call(name, {})

	assert(return_value == "post_modified", "Post-hook with return should modify the overall return value")
end)

-- Post-Hook without return not modifying overall return value
TEST(function(name)
	local return_value = nil
	Add(name, "normalhook", function()
		return "original_return"
	end, NORMAL_HOOK)
	Add(name, "posthook", function() end, POST_HOOK)

	return_value = Call(name, {})

	assert(return_value == "original_return", "Post-hook without return should not modify the overall return value")
end)

-- Post-Hok running after gamemode function
TEST(function(name)
	local gm_table = {}
	gm_table[name] = function()
		return "gm_called"
	end
	local posthook_ran = false
	Add(name, "postHook", function()
		posthook_ran = true
	end, POST_HOOK)

	local return_value = Call(name, gm_table)

	assert(posthook_ran and return_value == "gm_called", "Post-hook should run after gamemode function")
end)

-- Post-Hook modifying gamemode function return value
TEST(function(name)
	local gm_table = {}
	gm_table[name] = function()
		return "gm_called"
	end
	Add(name, "postHookreturn", function()
		return "post_modified"
	end, POST_HOOK_RETURN)

	local return_value = Call(name, gm_table)

	assert(return_value == "post_modified", "Post-hook should modify the return value of the gamemode function")
end)

-- Hook remove during execution
TEST(function(name)
	local hookran = false
	local removing_hook = function()
		Remove(name, "dynamicHook")
	end
	Add(name, "removing_hook", removing_hook, PRE_HOOK)
	Add(name, "dynamicHook", function()
		hookran = true
	end, NORMAL_HOOK)

	Call(name, {})

	assert(not hookran, "Hook should not run after being removed")
end)

-- Test weird adding in calls
TEST(function(name)
	local a, b, b2, c
	Add(name, "a", function()
		a = true
		Remove(name, "a")
		Add(name, "b", function()
			b2 = true
		end)
	end)

	Add(name, "c", function()
		c = true
	end)

	Add(name, "b", function()
		b = true
	end)

	Call(name)
	assert(a == true and b == nil and b2 == true and c == true, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " b2: " .. tostring(b2) .. " c: " .. tostring(c))
	a, b, b2, c = nil, nil, nil, nil
	Call(name)
	assert(a == nil and b == nil and b2 == true and c == true, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " b2: " .. tostring(b2) .. " c: " .. tostring(c))
end)

-- Test adding a hook inside hook.Call to make sure that the new added hook wont be called in the current hook.Call
-- gmod default behavior is wrong here, read https://github.com/Facepunch/garrysmod/pull/1642#issuecomment-601288451
TEST(function(name)
	local a, b, c
	Add(name, "a", function()
		a = true
		Add(name, "c", function()
			c = true
		end)
	end)
	Add(name, "b", function()
		b = true
	end)

	Call(name)
	assert(a == true and b == true and c == nil, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " c: " .. tostring(c))
	a, b, c = nil, nil, nil
	Call(name)
	assert(a == true and b == true and c == true, "something is wrong, called: a: " .. tostring(a) .. " b: " .. tostring(b) .. " c: " .. tostring(c))
end)

-- Test calling with no return values in normal hook, gm should run
TEST(function(name)
	local gm_called, normal_called, post_called

	local gm_table = {
		[name] = function(gm)
			gm_called = true
		end,
	}

	Add(name, "NORMAL_HOOK", function()
		normal_called = true
	end)

	Add(name, "POST_HOOK_RETURN", function(returned_value)
		assert(returned_value[1] == gm_table, "something is wrong")
		post_called = true
	end, POST_HOOK_RETURN)

	assert(
		Call(name, gm_table) == nil and normal_called == true and post_called == true and gm_called == true,
		"something is wrong: normal_called: " .. tostring(normal_called) .. " post_called: " .. tostring(post_called) .. " gm_called: " .. tostring(gm_called)
	)
end)

-- Test calling with return values in normal hook, gm should not run
TEST(function(name)
	local gm_called, normal_called, post_called

	local gm_table = {
		[name] = function(gm)
			gm_called = true
		end,
	}

	Add(name, "NORMAL_HOOK", function()
		normal_called = true
		return "NORMAL_HOOK"
	end)

	Add(name, "POST_HOOK_RETURN", function(returned_value)
		assert(returned_value[1] == "NORMAL_HOOK", "something is wrong")
		post_called = true
	end, POST_HOOK_RETURN)

	local returned = Call(name, gm_table)
	assert(
		returned == "NORMAL_HOOK" and normal_called == true and post_called == true and gm_called == nil,
		"something is wrong: returned: " .. tostring(returned) .. " normal_called: " .. tostring(normal_called) .. " post_called: " .. tostring(post_called) .. " gm_called: " .. tostring(gm_called)
	)
end)

-- Test calling with no return values in normal hook, and gm returns values
TEST(function(name)
	local gm_called, normal_called, post_called

	local gm_table = {
		[name] = function(gm)
			gm_called = true
			return "GM_RETURN"
		end,
	}

	Add(name, "NORMAL_HOOK", function()
		normal_called = true
	end)

	Add(name, "POST_HOOK_RETURN", function(returned_value)
		assert(returned_value[1] == gm_table and returned_value[2] == "GM_RETURN", "something is wrong")
		post_called = true
	end, POST_HOOK_RETURN)

	local returned = Call(name, gm_table)
	assert(
		returned == "GM_RETURN" and normal_called == true and post_called == true and gm_called == true,
		"something is wrong: returned: " .. tostring(returned) .. " normal_called: " .. tostring(normal_called) .. " post_called: " .. tostring(post_called) .. " gm_called: " .. tostring(gm_called)
	)
end)

-- Test calling with post hook modifies normal hook return, gm shouldnt run
TEST(function(name)
	local gm_called, normal_called, post_called

	local gm_table = {
		[name] = function(gm)
			gm_called = true
		end,
	}

	Add(name, "NORMAL_HOOK", function()
		normal_called = true
		return "NORMAL_HOOK"
	end)

	Add(name, "POST_HOOK_RETURN", function(returned_value)
		assert(returned_value[1] == "NORMAL_HOOK", "something is wrong")
		post_called = true
		return "POST_HOOK_RETURN"
	end, POST_HOOK_RETURN)

	local returned = Call(name, gm_table)
	assert(
		returned == "POST_HOOK_RETURN" and normal_called == true and post_called == true and gm_called == nil,
		"something is wrong: returned: " .. tostring(returned) .. " normal_called: " .. tostring(normal_called) .. " post_called: " .. tostring(post_called) .. " gm_called: " .. tostring(gm_called)
	)
end)

-- Test calling with post hook modifies gm function return
TEST(function(name)
	local gm_called, normal_called, post_called

	local gm_table = {
		[name] = function(gm)
			gm_called = true
			return "GM_RETURN"
		end,
	}

	Add(name, "NORMAL_HOOK", function()
		normal_called = true
	end)

	Add(name, "POST_HOOK_RETURN", function(returned_value)
		assert(returned_value[1] == gm_table and returned_value[2] == "GM_RETURN", "something is wrong")
		post_called = true
		return "POST_HOOK_RETURN"
	end, POST_HOOK_RETURN)

	local returned = Call(name, gm_table)
	assert(
		returned == "POST_HOOK_RETURN" and normal_called == true and post_called == true and gm_called == true,
		"something is wrong: returned: " .. tostring(returned) .. " normal_called: " .. tostring(normal_called) .. " post_called: " .. tostring(post_called) .. " gm_called: " .. tostring(gm_called)
	)
end)

TEST(function(name)
	local call_orders = {}
	Add(name, "PRE_HOOK", function(arg1, arg2, arg3)
		assert(arg1 == 1 and arg2 == 2 and arg3 == 3, "PRE_HOOK didn't get the right argument")
		insert(call_orders, PRE_HOOK)
	end, PRE_HOOK)

	Add(name, "PRE_HOOK_RETURN", function(arg1, arg2, arg3)
		assert(arg1 == 1 and arg2 == 2 and arg3 == 3, "PRE_HOOK_RETURN didn't get the right argument")
		insert(call_orders, PRE_HOOK_RETURN)
	end, PRE_HOOK_RETURN)

	Add(name, "NORMAL_HOOK", function(arg1, arg2, arg3)
		assert(arg1 == 1 and arg2 == 2 and arg3 == 3, "NORMAL_HOOK didn't get the right argument")
		insert(call_orders, NORMAL_HOOK)
		return "testing_returns"
	end, NORMAL_HOOK)

	Add(name, "POST_HOOK_RETURN", function(returned_values, arg1, arg2, arg3)
		assert(returned_values[1] == "NORMAL_HOOK" and returned_values[2] == "testing_returns" and arg1 == 1 and arg2 == 2 and arg3 == 3, "POST_HOOK_RETURN didn't get the right argument")
		insert(call_orders, POST_HOOK_RETURN)
		return "testing_post_return"
	end, POST_HOOK_RETURN)

	Add(name, "POST_HOOK", function(returned_values, arg1, arg2, arg3)
		assert(returned_values[1] == "POST_HOOK_RETURN" and returned_values[2] == "testing_post_return" and arg1 == 1 and arg2 == 2 and arg3 == 3, "POST_HOOK didn't get the right argument")
		insert(call_orders, POST_HOOK)
	end, POST_HOOK)

	Call(name, nil, 1, 2, 3)

	local expected_call_orders = {
		PRE_HOOK,
		PRE_HOOK_RETURN,
		NORMAL_HOOK,
		POST_HOOK_RETURN,
		POST_HOOK,
	}

	for i = 1, #expected_call_orders do
		if call_orders[i] ~= expected_call_orders[i] then
			error("something is wrong, expected: " .. expected_call_orders[i][1] .. " got: " .. call_orders[i][1])
		end
	end
end)

TEST(function(name)
	local entity = {
		IsValid = function()
			return true
		end,
	}

	Add(name, entity, function()
		return true
	end)

	assert(Call(name, nil, 1) == true, "hook.Call didn't run the hook or returned the wrong value")
end)

TEST(function(name)
	local called = 1
	local entity = {
		IsValid = function()
			called = called + 1
			if called <= 2 then
				return true
			end
			return false
		end,
	}

	Add(name, entity, function()
		return true
	end)

	assert(Call(name, nil, 1) == true, "hook.Call didn't run the hook or returned the wrong value")
	assert(Call(name, nil, 1) == nil, "hook.Call entity was called even though it became invalid")
end)

TEST(function(name)
	local entity = {
		IsValid = function()
			return true
		end,
	}

	local entity_call_count = 0
	Add(name, entity, function()
		entity_call_count = entity_call_count + 1
	end)

	local call_count = 0
	Add(name, "1", function()
		call_count = call_count + 1
		return 1
	end)

	assert(Call(name, nil, 1) == 1, "hook.Call didn't run the hook or returned the wrong value")
	assert(call_count == 1, "call count is wrong: " .. call_count)
	assert(entity_call_count == 1, "entity call count is wrong: " .. entity_call_count)

	call_count = 0
	assert(Call(name, nil, 1) == 1, "hook.Call didn't run the hook or returned the wrong value")
	assert(call_count == 1, "call count is wrong: " .. call_count)
end)

TEST(function(name)
	Add(name, "1", function()
		Remove(name, "1")
	end)

	Add(name, "2", function()
		return 1
	end, POST_HOOK_RETURN)

	Call(name, nil, 1)
end)

TEST(function(name)
	local called = false

	Add(name, "1", function()
		return 1
	end, PRE_HOOK)

	Add(name, "2", function()
		called = true
		return 2
	end, PRE_HOOK)

	Call(name)
	assert(called == true, "hook.Call didn't run the hook or returned the wrong value")
end)

return Hook
