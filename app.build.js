({
    baseUrl: ".",
    paths: {
        "jquery": "require-jquery"
    },
    dir: "build",
    stubModules: ['cs'],
    optimize:"none",
    modules: [
        {
            name: "main",
            exclude: ["jquery", "coffee-script"]
        }
    ]
})
