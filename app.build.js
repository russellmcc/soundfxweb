({
    baseUrl: ".",
    paths: {
        "jquery": "require-jquery"
    },
    dir: "build",
    stubModules: ['cs'],
    modules: [
        {
            name: "main",
            exclude: ["jquery", "coffee-script"]
        }
    ]
})
