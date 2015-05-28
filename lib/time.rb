class ::Time
  # This is a dirty monkey patch to get ticks since epoch from Time class.
  # This is used to generate unique filenames.
  
  # See http://msdn.microsoft.com/en-us/library/system.datetime.ticks.aspx
  
  TICKS_SINCE_EPOCH = Time.utc(0001,01,01).to_i * 10000000
 
  def ticks
    to_i * 10000000 + nsec / 100 - TICKS_SINCE_EPOCH
  end
end