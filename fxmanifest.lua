fx_version 'bodacious'
game 'gta5'

name 'Chat Management'
description 'Chat default UI Edited'
author 'BlasterrSuraj'

ui_page 'html/index.html'

-- client_script 'cl_chat.lua'
shared_script 'config.lua'

client_scripts {
	'cl_chat.lua'
}

server_script 'sv_chat.lua'

files {
  'html/index.html',
  'html/css/style.css',
  'html/js/config.default.js',
  'html/js/App.js',
  'html/js/Message.js',
  'html/js/Suggestions.js',
  'html/vendor/vue.2.3.3.min.js',
  'html/vendor/flexboxgrid.6.3.1.min.css',
  'html/vendor/animate.3.5.2.min.css',
}
