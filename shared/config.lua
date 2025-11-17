local Environment = {
	DEBUG = 1,
	STAGING = 2,
	PRODUCTION = 3,
}

return {
	allowHotReload = true,
	runTests = false,
	environment = Environment.DEBUG,
	Environment = Environment,
}
