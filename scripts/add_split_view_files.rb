#!/usr/bin/env ruby
# Registers the split-out island view files (EnergyTradeViews / TxReceiptViews)
# into the app + widget targets. The EnergyIslandWidget/ group uses explicit
# file references, so new files there need registering. Idempotent.
require 'xcodeproj'

PROJECT = 'gridtokexios.xcodeproj'
WIDGET  = 'EnergyIslandWidget'
APP     = 'gridtokexios'

project = Xcodeproj::Project.open(PROJECT)
app    = project.targets.find { |t| t.name == APP }    or abort "app target missing"
widget = project.targets.find { |t| t.name == WIDGET } or abort "widget target missing"
group  = project.main_group.find_subpath(WIDGET, false) or abort "#{WIDGET} group missing"

shared = %w[EnergyTradeViews.swift TxReceiptViews.swift]   # app + widget

def ref_for(group, fname)
  group.files.find { |f| f.path == fname } || group.new_reference(fname)
end

def ensure_member(target, ref)
  return if target.source_build_phase.files_references.include?(ref)
  target.source_build_phase.add_file_reference(ref)
end

shared.each do |fname|
  ref = ref_for(group, fname)
  ensure_member(widget, ref)
  ensure_member(app, ref)
end

project.save
puts "registered split view files: #{shared.join(', ')}"
