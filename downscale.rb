#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sidekiq/api'
require 'open3'

# Bypadd STDOUT buffering for logging
$stdout.sync = true

processes = Sidekiq::ProcessSet.new
idle_dumpworkers = processes.select { |process| process.identity =~ /dumpworker/ && process['busy'].zero? }

pod_count_cmd = "kubectl get deployment #{ENV.fetch('DEPLOYMENT_NAME')} -o jsonpath='{.spec.replicas}'"
pod_count, pod_count_stderr, pod_count_status = Open3.capture3(pod_count_cmd)

if pod_count_status.exitstatus > 0
  puts "Error contacting kubernetes cluster: #{pod_count_stderr}"
  exit
end

if idle_dumpworkers.count.zero?
  puts 'No idle dumpworkers to scale'
elsif pod_count.to_i == ENV.fetch('MINIMUM_PODS').to_i
  puts 'Already scaled to minimum pods'
else
  killable_pod_name = idle_dumpworkers[0]['hostname']
  kill_cmd = "kubectl delete pod #{killable_pod_name}"
  kill_output, kill_stderr = Open3.capture3(kill_cmd)
  puts kill_output || kill_stderr

  new_desired_pod_count = pod_count.to_i - 1
  scale_cmd = "kubectl scale deployment #{ENV.fetch('DEPLOYMENT_NAME')} --replicas=#{new_desired_pod_count}"
  scale_output, scale_stderr = Open3.capture3(scale_cmd)
  puts scale_output || scale_stderr
end
