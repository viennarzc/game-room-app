#!/usr/bin/env ruby

gem "rexml", "= 3.4.2"
require "rexml/document"
require "xcodeproj"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
PROJECT_PATH = File.join(ROOT, "Game Room.xcodeproj")

project = Xcodeproj::Project.open(PROJECT_PATH)

main_target = project.targets.find { |target| target.name == "Game Room" }
abort("Game Room target not found") unless main_target

desired_target_names = ["Game Room", "Game RoomTests", "Game RoomUITests"]
project.targets.reject { |target| desired_target_names.include?(target.name) }.each(&:remove_from_project)

unit_target = project.targets.find { |target| target.name == "Game RoomTests" }
unit_target ||= project.new_target(:unit_test_bundle, "Game RoomTests", :ios, "26.0")

ui_target = project.targets.find { |target| target.name == "Game RoomUITests" }
ui_target ||= project.new_target(:ui_test_bundle, "Game RoomUITests", :ios, "26.0")

[main_target, unit_target, ui_target].each do |target|
  target.dependencies.each(&:remove_from_project)
end

desired_products = [main_target, unit_target, ui_target].map(&:product_reference)
project.products_group.children.dup.each do |product|
  next if desired_products.include?(product)
  product.remove_from_project
end

main_target.build_phases.dup.each(&:remove_from_project)
main_sources_phase = project.new(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
main_resources_phase = project.new(Xcodeproj::Project::Object::PBXResourcesBuildPhase)
main_frameworks_phase = project.new(Xcodeproj::Project::Object::PBXFrameworksBuildPhase)
main_target.build_phases << main_sources_phase
main_target.build_phases << main_resources_phase
main_target.build_phases << main_frameworks_phase

project.main_group.children.dup.each do |child|
  next if child == project.products_group
  child.remove_from_project
end

def add_directory(group, absolute_path, source_phase: nil, resource_phase: nil)
  Dir.children(absolute_path).sort.each do |entry|
    next if entry.start_with?(".")

    absolute_entry = File.join(absolute_path, entry)
    if File.directory?(absolute_entry)
      if entry.end_with?(".xcassets")
        reference = group.new_file(entry)
        resource_phase&.add_file_reference(reference)
      else
        child_group = group.new_group(entry, entry)
        add_directory(
          child_group,
          absolute_entry,
          source_phase: source_phase,
          resource_phase: resource_phase
        )
      end
    else
      reference = group.new_file(entry)
      source_phase&.add_file_reference(reference) if File.extname(entry) == ".swift"
    end
  end
end

app_group = project.main_group.new_group("App", "App")
add_directory(
  app_group,
  File.join(ROOT, "App"),
  source_phase: main_sources_phase,
  resource_phase: main_resources_phase
)

tests_group = project.main_group.new_group("Tests", "Tests")
ui_tests_group = project.main_group.new_group("UITests", "UITests")
deferred_group = project.main_group.new_group("Deferred", "Deferred")
docs_group = project.main_group.new_group("Docs", "Docs")
project.main_group.new_file("README.md")
project.main_group.new_file("Project.json")

add_directory(deferred_group, File.join(ROOT, "Deferred"))
add_directory(docs_group, File.join(ROOT, "Docs"))

def configure_main_target(target)
  target.build_configurations.each do |configuration|
    settings = configuration.build_settings
    settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
    settings["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"] = "AccentColor"
    settings["CODE_SIGN_ENTITLEMENTS"] = "App/New Project.entitlements"
    settings["CURRENT_PROJECT_VERSION"] = "1"
    settings["GENERATE_INFOPLIST_FILE"] = "NO"
    settings["INFOPLIST_FILE"] = "App/Info.plist"
    settings["INFOPLIST_FILE[sdk=macosx*]"] = "App/Info-macOS.plist"
    settings["IPHONEOS_DEPLOYMENT_TARGET"] = "26.0"
    settings["MACOSX_DEPLOYMENT_TARGET"] = "26.0"
    settings["MARKETING_VERSION"] = "1.0"
    settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.vnrz.gameroom"
    settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
    settings["SDKROOT"] = "auto"
    settings["SWIFT_VERSION"] = "6.0"
    settings["XROS_DEPLOYMENT_TARGET"] = "26.0"

    if configuration.name == "Debug"
      settings["SUPPORTED_PLATFORMS"] = "iphoneos iphonesimulator macosx xros xrsimulator"
      settings["TARGETED_DEVICE_FAMILY"] = "1,2,7"
    else
      settings["SUPPORTED_PLATFORMS"] = "iphoneos iphonesimulator"
      settings["TARGETED_DEVICE_FAMILY"] = "1,2"
    end
  end
end

configure_main_target(main_target)

project.root_object.attributes["TargetAttributes"] = {
  main_target.uuid => {
    "SystemCapabilities" => {
      "com.apple.BackgroundModes" => { "enabled" => 1 },
      "com.apple.iCloud" => { "enabled" => 1 },
      "com.apple.Push" => { "enabled" => 1 }
    }
  }
}

unit_target.source_build_phase.files.dup.each(&:remove_from_project)
unit_target.add_dependency(main_target)
add_directory(tests_group, File.join(ROOT, "Tests"), source_phase: unit_target.source_build_phase)

ui_target.source_build_phase.files.dup.each(&:remove_from_project)
ui_target.add_dependency(main_target)
add_directory(ui_tests_group, File.join(ROOT, "UITests"), source_phase: ui_target.source_build_phase)

[
  [unit_target, "com.vnrz.gameroom.tests"],
  [ui_target, "com.vnrz.gameroom.uitests"]
].each do |target, bundle_identifier|
  target.build_configurations.each do |configuration|
    settings = configuration.build_settings
    settings["GENERATE_INFOPLIST_FILE"] = "YES"
    settings["IPHONEOS_DEPLOYMENT_TARGET"] = "26.0"
    settings["PRODUCT_BUNDLE_IDENTIFIER"] = bundle_identifier
    settings["SWIFT_VERSION"] = "6.0"
    settings["TARGETED_DEVICE_FAMILY"] = "1,2"
  end
end

ui_target.build_configurations.each do |configuration|
  configuration.build_settings["TEST_TARGET_NAME"] = "Game Room"
end

unit_target.build_configurations.each do |configuration|
  configuration.build_settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
  configuration.build_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/Game Room.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Game Room"
end

valid_configuration_lists = [project.build_configuration_list] + project.targets.map(&:build_configuration_list)
project.objects
  .select { |object| object.isa == "XCConfigurationList" && !valid_configuration_lists.include?(object) }
  .each do |configuration_list|
    configuration_list.build_configurations.dup.each(&:remove_from_project)
    configuration_list.remove_from_project
  end

project.save

scheme_directory = File.join(PROJECT_PATH, "xcshareddata", "xcschemes")
FileUtils.mkdir_p(scheme_directory)
scheme_path = File.join(scheme_directory, "Game Room.xcscheme")
File.write(scheme_path, <<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <Scheme LastUpgradeVersion="2660" version="1.7">
    <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
        <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
          <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{main_target.uuid}" BuildableName="Game Room.app" BlueprintName="Game Room" ReferencedContainer="container:Game Room.xcodeproj"/>
        </BuildActionEntry>
      </BuildActionEntries>
    </BuildAction>
    <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables>
        <TestableReference skipped="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{unit_target.uuid}" BuildableName="Game RoomTests.xctest" BlueprintName="Game RoomTests" ReferencedContainer="container:Game Room.xcodeproj"/></TestableReference>
        <TestableReference skipped="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{ui_target.uuid}" BuildableName="Game RoomUITests.xctest" BlueprintName="Game RoomUITests" ReferencedContainer="container:Game Room.xcodeproj"/></TestableReference>
      </Testables>
    </TestAction>
    <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{main_target.uuid}" BuildableName="Game Room.app" BlueprintName="Game Room" ReferencedContainer="container:Game Room.xcodeproj"/></BuildableProductRunnable>
    </LaunchAction>
    <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{main_target.uuid}" BuildableName="Game Room.app" BlueprintName="Game Room" ReferencedContainer="container:Game Room.xcodeproj"/></BuildableProductRunnable></ProfileAction>
    <AnalyzeAction buildConfiguration="Debug"/>
    <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
  </Scheme>
XML

puts "Regenerated #{PROJECT_PATH}"
