def pbcopy(arg) = IO.popen("pbcopy", "w") { |io| io.puts(arg) }
