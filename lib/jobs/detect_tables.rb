require './local_settings'

class DetectTablesJob
  # args: (:file, :output_dir, :thumbnail_size)
  include Resque::Plugins::Status
  Resque::Plugins::Status::Hash.expire_in = (90 * 60) # 30min
  @queue = :pdftohtml

  def perform
    file_id = options['file_id']
    base_path = options['base_path']
    _stdin, _stdout, _stderr, thr = Open3.popen3(
        {"CLASSPATH" => "./lib/jars/javacpp.jar:./lib/jars/javacv.jar:./lib/jars/javacv-macosx-x86_64.jar:./lib/jars/PDFRenderer-0.9.1.jar"},
        "#{Settings::JRUBY_PATH} --1.9 --server lib/jruby_table_guesser.rb #{file_id} #{base_path}"
    )
    _stderr.each { |line|  STDERR.puts(line) } #passthru
    _stdin.close
    _stdout.close
    _stderr.close

    return nil
  end
end