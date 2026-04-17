#!/usr/bin/env ruby

# frozen_string_literal: true

# rubocop: disable Metrics

require 'json'
require 'rainbow/refinement'
require 'git'

using Rainbow

now = Time.now
week_percentage = (((now.wday * 86_400) + (now.hour * 3_600) + (now.min * 60) + now.sec) * 100.0 / (7 * 86_400)).round

def warn_colors(text, var, good: ->(_) { false }, warn: ->(_) { false }, bad: ->(_) { false }, hide: ->(_) { false })
  if hide.call(var)
    ''
  elsif bad.call(var)
    text.red.bright
  elsif warn.call(var)
    text.yellow
  elsif good.call(var)
    text.green
  else
    text
  end
end

claude = JSON.parse($stdin.gets.chomp)

model = claude.dig('model', 'display_name') || 'unknown'

context_window = claude['context_window'] || {}
context_pct = context_window['used_percentage'] || 0

rate_limits = claude['rate_limits'] || {}
session_rl = rate_limits['five_hour'] || {}
session_pct = session_rl['used_percentage'] || 0

week_rl = rate_limits['seven_day'] || {}
week_pct = week_rl['used_percentage'] || 0

workspace = claude['workspace'] || {}
project_dir = workspace['project_dir'].split('/').last || ''

sections = {}

repo = Git.open('.') || nil

sections['git'] = ''
sections['git'] = "on  #{repo.branch.name}" unless repo.nil?

sections['path'] = project_dir

caveman_flag = File.join(Dir.home, '.claude', '.caveman-active')
sections['caveman'] = if File.exist?(caveman_flag)
                        mode = File.read(caveman_flag).strip
                        if mode.empty? || mode == 'full'
                          '[CAVEMAN]'
                        else
                          "[CAVEMAN:#{mode.upcase}]"
                        end
                      else
                        '[ NO CAVEMAN]'.yellow
                      end

sections['model'] = if model.downcase =~ /sonnet/
                      ''
                    elsif model.downcase =~ /opus/
                      " #{model}".red.bright
                    else
                      " #{model}".yellow
                    end

session_end = session_rl['resets_at'] ? Time.at(session_rl['resets_at']).strftime('%H:%M') : nil
session_rl_label = session_end ? "#{session_pct}% usage until #{session_end}" : "#{session_pct}% 󰓅"
sections['session_rl'] = warn_colors("[#{session_rl_label}]",
                                     session_pct,
                                     bad: ->(x) { x > 75 },
                                     warn: ->(x) { x >= 50 },
                                     good: ->(x) { x > 25 })
sections['context_window'] = warn_colors("[#{context_pct}% context]",
                                         context_pct,
                                         bad: ->(x) { x > 75 },
                                         warn: ->(x) { x > 50 },
                                         hide: ->(x) { x < 25 })

sections['week_rl'] = warn_colors("[#{week_pct.floor}%]",
                                  week_pct,
                                  bad: ->(x) { x * 1.5 > week_percentage },
                                  warn: ->(x) { x > week_percentage },
                                  hide: ->(x) { x <= week_percentage })

puts [sections['path'], sections['git'], sections['week_rl'], sections['model'], sections['caveman'],
      sections['session_rl'],
      sections['context_window']].reject(&:empty?).join(' ')
