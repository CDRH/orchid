// Compatible with Sprockets 3.x defaults to avoid breaking existing apps
// https://github.com/rails/sprockets/blob/master/UPGRADING.md#manifestjs
//= link application.css
//= link application.js

// Sprockets 4.x defaults
//= link_tree ../images
//= link_directory ../javascripts .js
//= link_directory ../stylesheets .css

// Orchid engine's manifest: orchid/app/assets/config/orchid/manifest.js
//= link orchid/manifest.js

// Include all Rails app assets from directories inside /vendor/assets
//= link_tree ../../../vendor/assets
