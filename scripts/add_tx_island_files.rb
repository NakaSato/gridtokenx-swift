#!/usr/bin/env ruby
# Adds the TX-success Live Activity source files to the right targets.
# The EnergyIslandWidget/ group uses explicit file references (not a synced
# folder), so new files must be registered here. Idempotent: re-running only
# adds references / build-file memberships that are missing.
require 'xcodeproj'

PROJECT = 'gridtokexios.xcodeproj'
WIDGET  = 'EnergyIslandWidget'
APP     = 'gridtokexios'

project = Xcodeproj::Project.open(PROJECT)
app    = project.targets.find { |t| t.name == APP }    or abort "app target missing"
widget = project.targets.find { |t| t.name == WIDGET } or abort "widget target missing (run add_widget_target.rb first)"
group  = project.main_group.find_subpath(WIDGET, false) or abort "#{WIDGET} group missing"

shared      = %w[TxReceiptIsland.swift TxReceiptAttributes.swift]   # app + widget
widget_only = %w[TxLiveActivity.swift]                             # widget only

def ref_for(group, fname)
  group.files.find { |f| f.path == fname } || group.new_reference(fname)
end

def ensure_member(target, ref)
  return if target.source_build_phase.files_references.include?(ref)
  target.source_build_phase.add_file_reference(ref)
end

(shared + widget_only).each do |fname|
  ref = ref_for(group, fname)
  ensure_member(widget, ref)
  ensure_member(app, ref) if shared.include?(fname)
end

project.save
puts "registered TX island files (shared: #{shared.join(', ')}; widget-only: #{widget_only.join(', ')})"
