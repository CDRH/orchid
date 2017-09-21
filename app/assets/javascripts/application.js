// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets

// Declaring assets for auto and precompilation with link_tree directives
// bypasses the need to add assets to the list of paths in the config variable
// Rails.application.config.assets.precompile in config/initializers/assets.rb

// Include Orchid asset declarations and Orchid-wide scripting from Orchid gem
//= require orchid

// Declare this app's assets
//= link_tree . .js
//= link_tree ../images
//= link_tree ../stylesheets .css

// Include app-wide scripting from "global" sub-directory
// Note: require_directory won't include .js files from framework subdirectories
// They are declared for auto and precompilation by link_tree above though
//= require_directory ./global
