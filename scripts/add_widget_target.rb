#!/usr/bin/env ruby
# Adds the EnergyIslandWidget app-extension target (Live Activity / Dynamic Island)
# to gridtokexios.xcodeproj. Idempotent: re-running is a no-op once the target exists.
require 'xcodeproj'

PROJECT = 'gridtokexios.xcodeproj'
WIDGET  = 'EnergyIslandWidget'
APP     = 'gridtokexios'
DEPLOY  = '26.5'
APP_BUNDLE = 'gridtokenx.gridtokexios'

project = Xcodeproj::Project.open(PROJECT)
app = project.targets.find { |t| t.name == APP } or abort "app target #{APP} not found"

if project.targets.any? { |t| t.name == WIDGET }
  puts "#{WIDGET} target already exists — nothing to do"
  exit 0
end

widget = project.new_target(:app_extension, WIDGET, :ios, DEPLOY, nil, :swift)

widget.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = "#{APP_BUNDLE}.#{WIDGET}"
  s['INFOPLIST_FILE'] = "#{WIDGET}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['INFOPLIST_KEY_CFBundleDisplayName'] = 'Energy Island'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOY
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['MARKETING_VERSION'] = '1.0'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks',
                                  '@executable_path/../../Frameworks']
  s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = (c.name == 'Debug' ? 'DEBUG' : '')
end

group = project.main_group.find_subpath(WIDGET, true)
group.set_source_tree('SOURCE_ROOT')
group.set_path(WIDGET)

shared = %w[EnergyTradeIsland.swift EnergyTradeAttributes.swift]   # app + widget
widget_only = %w[ColorHex.swift EnergyIslandLiveActivity.swift EnergyIslandWidgetBundle.swift]

(shared + widget_only).each do |fname|
  ref = group.new_reference(fname)
  widget.source_build_phase.add_file_reference(ref)
  app.source_build_phase.add_file_reference(ref) if shared.include?(fname)
end
group.new_reference('Info.plist')   # visible, used as INFOPLIST_FILE (not compiled)

# App embeds + depends on the extension.
app.add_dependency(widget)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
bf = embed.add_file_reference(widget.product_reference)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# App opts into Live Activities.
app.build_configurations.each do |c|
  c.build_settings['INFOPLIST_KEY_NSSupportsLiveActivities'] = 'YES'
end

project.save
puts "added #{WIDGET} target, embedded into #{APP}, enabled Live Activities"
