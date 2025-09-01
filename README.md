# TabToClose

Morrowind mod for users that use tab to close UI elements (e.g., inventory UI).

## Build

- This simple mod was partly made to try out the Teal language, a typed dialect of lua, which compiles to lua.
- If you don't want to touch teal: you can directly edit the .lua files. You could even delete the .tl files in your fork.
- If you want to use teal: edit the .tl files (you will need tl/cyan installed to compile them to .lua files)
    - Personally, I have an event that triggers in my editor (nvim for this project) every time I save a file that triggers cyan to re-compile the entire project (which is fast enough for a small project like this).

## Thoughts on Teal/Cyan/OpenMW combination

My reason for using teal is mostly for auto-completion. The lua version of OpenMW API, doesn't really supply the Lau language server with auto-complete information. Teal, on the other hand, gives teal declaration files, which gives the Teal Language Server autocomplete information.
- The teal declaration files are not complete enough. There are some things missing. For example. the l10n function in core.d.tl was given a more specific return type in this project.
    - It used to just return a `function`, but now it returns `function(string, ?table):string`, which is more specific and accurate.
    - There are more examples of things missing such as the argument parameter in settings (which is different depending on the type of setting it is (e.g., checkbox, select, etc.))
    - More over, things like `renderer` for settings can only have certain string values, but this is not specified in the declarations. I would have loved to specify it with an Enum, but you actually cant pick values from enums yet with teal (e.g., `RendererEnum.checkbox`).
    - All this being said, there is more auto-completion with teal than without and I didn't have to check the documentation as much, but I still had to check it every now and then.


- The Cyan build tool for Teal allows you to specify the build path and src path, so you can put all your teal files in src and all your generated lua files in build, but when you `require()` modules in teal, these module paths are NOT translated when generating lua files, which causes a error when modules are not found.
    - Even worse, openMW does NOT allow you to edit the `package.path` since it is sandboxed. So, you cannot tell lua to look for the packages in the appropriate build path.
    - This forces you to build all teal (src) and lua (build) in the same folders!
    - tlconfig.lua and the .omwscript file must also be in the same path in order to require() files correctly between the teal language server and OpenMW.


- Getting the teal declaration files for openMW is currently a hassle. The URL pointed at by the [documentation](https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/teal.html) simply 404's.
    - Instead, you must find it through GitLab's pipeline tab: [https://gitlab.com/OpenMW/openmw/-/pipelines?page=1&scope=all&ref=openmw-49](https://gitlab.com/OpenMW/openmw/-/pipelines?page=1&scope=all&ref=openmw-49)
        - Find the correct commit, and then download the artifact.