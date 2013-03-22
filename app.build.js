({
    baseUrl: "src",
    paths: {
        "jquery": "require-jquery"
    },
    dir: "build/src",
    stubModules: ['cs'],
    modules: [
        {
            name: "main",
            exclude: ["jquery", "coffee-script"]
        }
    ]
})
