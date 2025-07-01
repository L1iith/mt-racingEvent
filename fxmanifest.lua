fx_version 'cerulean'
game 'gta5'

name 'Racing Tournament'
author 'Racing Tournament Team'
description 'Complete FiveM Racing Tournament Management System'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'shared/locale.lua',
    'shared/config.lua'
}

client_scripts {
    '@qb-core/client/functions.lua',
    'client/main.lua',
    'client/npc.lua',
    'client/ui.lua',
    'client/zones.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/database.lua',
    'server/callbacks.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/components/*.svelte',
    'nui/stores/*.js'
}

dependencies {
    'qb-core',
    'oxmysql',
    'ox_lib'
}

lua54 'yes'