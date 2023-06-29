set_project("simp_lang")
set_version("1.0.0")
set_xmakever("2.7.9")

set_languages("c17", "cxx17")
add_rules("mode.debug", "mode.release", "plugin.compile_commands.autoupdate")
add_cxflags("-std=c17", { force = true })

local libs = { "fmt", "gtest" }

add_includedirs("/usr/include", "/usr/local/include", "include")
add_requires(table.unpack(libs))

target("simp_lang-lib")
  set_kind("static")
  add_rules("lex", "yacc")
  add_files("src/**/*.c", "src/**/*.l", "src/**/*.y")
  add_packages(table.unpack(libs))

target("simp_lang")
  set_kind("binary")
  add_files("standalone/main.c")
  add_packages(table.unpack(libs))
  add_deps("simp_lang-lib")

add_installfiles("(include/**)", {prefixdir = ""})
