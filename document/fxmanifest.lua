fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_scripts {
  "@es_extended/imports.lua",
  "config.lua"
}

client_script "client/main.lua"
server_script "server/main.lua"

ui_page "html/index.html"

files {
  "documents.json",
  "html/**"
}