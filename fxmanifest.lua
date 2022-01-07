fx_version 'adamant'

game 'gta5'

description 'Aquiver Object Controller'
author 'freamee'
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/server.lua',
}

dependencies {
    'mysql-async'
}

client_scripts {
    'config.lua',
    'client/client.lua',
    'client/cl_w2s.lua',
    'client/cl_aimcontroller.lua',
    'client/cl_functioncontroller.lua',
    'client/example.lua'
}