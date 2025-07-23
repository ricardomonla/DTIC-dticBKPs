#!/usr/bin/ruby
# frozen_string_literal: true

# NOMBRE DE APP ** dticBKPs_log.rb **
# Ricardo MONLA (rmonla@)
# Módulo de configuración de Logger para dticBKPs

require 'logger'
require 'fileutils'

module DticBKPsLogger
  def self.setup_logger(log_file_path)
    begin
      FileUtils.touch(log_file_path)
    rescue StandardError => e
      puts "Error crítico: No se puede crear o acceder al archivo de log '#{log_file_path}': #{e.message}"
      exit 1
    end

    logger = Logger.new(log_file_path)
    logger.level = Logger::INFO
    logger.formatter = proc do |severity, datetime, _, msg|
      icon = case severity
             when 'INFO' then 'ℹ️'
             when 'ERROR' then '❌'
             when 'WARN' then '⚠️'
             else '🔸'
             end
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{icon} #{msg}\n"
    end
    logger
  end
end