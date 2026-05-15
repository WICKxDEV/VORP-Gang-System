fx_version 'adamant'
games { 'rdr3' }

author 'WICKxDEV (https://github.com/WICKxDEV)'
description 'VORP Gang Management System'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

lua54 'yes'
